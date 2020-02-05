#########################################################################
#     Raman2imzML - Reinshaws raman data in .txt format converter to 
#                    imzML using rMSI's imzML creator source code.
#
#     Copyright (C) 2020 Lluc Semente Fernandez
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
############################################################################

#' convert
#' 
#' Converts a txt files exported using WiRe 5.2 from Renishaw raman instruments and transforms it into an imzML file. The name
#' of the imzML file is going to be the same as the txt file. Only WiRe 5.2 txt files have been tested. 
#' 
#' @param txt_path path to the txt file.
#' @param imzML_path path to the folder where the imzML file is going to be stored.
#'
#' @return  TRUE if everything is alright.
#'
#' @export
#'
convert <- function(txt_path, imzML_path)
{
  #Get file name and check if imzML directory exists, if not, create it.
  file_name <- unlist(strsplit(txt_path, split = "/"))
  file_name <- file_name[length(file_name)]
  file_name <- unlist(strsplit(file_name,split = ".txt"))
  
  if(!dir.exists(imzML_path))
  {
    dir.create(imzML_path)
  }
  
  
  #Raw data read and cleaning 
  raw_data <- as.data.frame(utils::read.table(file = txt_path, header = FALSE))
  clean_data <- raw_2_clean(raw_data)
  rm(raw_data)
  
  #UUID generation, .ibd file creation and hash calculation 
  uuid <- uuid_timebased()
  hash <- write_ibd(imzML_path, file_name, clean_data, uuid)
  clean_data$hash <- hash
  clean_data$hash$uuid <- uuid
  
  #Genereting the offset matrix and the .imzML file
  offset_matrix <- clean_2_offsetMatrix(clean_data)
  return(CimzMLStore(paste(imzML_path, file_name,".imzML", sep = ""), offset_matrix))
}


#' raw_2_clean
#' 
#' @param raw_data data frame containing the raw data from the txt file.
#'
#' @return  rearranged data to fit the processing pipeline. 
#' 
raw_2_clean <- function(raw_data)
{
  #Raman Shift Axis
  raman_shift <- union(raw_data[,3],raw_data[,3])
  band_length <- length(raman_shift)
  
  #Motor and relative coordenates
  x <- raw_data[seq(from = 1, to = nrow(raw_data)-(band_length-1), by = band_length), 1]
  y <- raw_data[seq(from = 1, to = nrow(raw_data)-(band_length-1), by = band_length), 2]
  number_pixels <- length(x)
  pixel_size <- abs(x[1]-x[2])
  motor_coords <- list(x = x, y = y)
  
  rel_x <- x
  for(i in 1:length(x)){
    rel_x[i] <- which(rel_x[i] == unique(x))
  }
  
  rel_y <- y
  for(i in 1:length(y)){
    rel_y[i] <- which(rel_y[i] == unique(y))
  }
  rel_coords <- list(x = rel_x, y = rel_y)
  
  #Intensity data filling
  intensity <- matrix(ncol = length(raman_shift), nrow = number_pixels)
  for(pixel in 1:number_pixels)
  {
    pixel_head <- 1+band_length*(pixel-1)
    pixel_tail <- band_length*(pixel)
    intensity[pixel,] <- raw_data[pixel_head:pixel_tail, 4]
  }
  
  #Clean data list creation
  clean_data <- list(ramanShift = raman_shift,
                     intensity = intensity,
                     posMotors = motor_coords,
                     pos = rel_coords,
                     pixelSize = pixel_size)
  
  return(clean_data)
}


#' write_ibd
#' 
#' @param imzML_path path to the folder where the imzML file is going to be stored..
#' @param file_name name of the txt file or a new name.(currently the converter just copies the txt file name) 
#' @param clean_data rearranged data structure.
#' @param uuid uuid. This code must be shared between the imzMl file and the ibd file. 
#' 
#' @return  List containing the sha and the md5 of the ibd file.
#' 
write_ibd <- function(imzML_path, file_name, clean_data, uuid)
{
  ibd_path <- paste(imzML_path,file_name,".ibd",sep = "")
  intUUID <- strtoi(substring(uuid, seq(1,nchar(uuid),2), seq(2,nchar(uuid),2)), base = 16)
  
  if (file.create(ibd_path))
  {
    ibd_conn <- file(ibd_path, "wb")
    writeBin(intUUID, ibd_conn, size = 1, endian = "little") #write UUID
    writeBin(clean_data$ramanShift, ibd_conn, size = 4, endian = "little", useBytes = T) #write raman shift axis
    for(pixel in 1:nrow(clean_data$intensity))
    {
      writeBin(clean_data$intensity[pixel,], ibd_conn, size = 4, endian = "little", useBytes = T) #write each pixel
    }
    sha <- digest::digest(ibd_conn, algo = "sha1")
    md5 <- digest::digest(ibd_conn, algo = "md5")
    close(ibd_conn)
  }
  else(stop("File could not be created"))
  
  return(list(sha = sha, md5 = md5))
}


#' clean_2_offsetMatrix
#' 
#' @param clean_data path to the .txt file.
#'
#' @return  TRUE if everything is alright.
#' 
clean_2_offsetMatrix <- function(clean_data)
{
  # Create the offset matrix
  offMat <- list()
  offMat$UUID <- clean_data$hash$uuid
  offMat$SHA <- clean_data$hash$sha
  offMat$MD5 <-  clean_data$hash$md5
  offMat$continuous_mode <- TRUE
  offMat$compression_mz <- FALSE
  offMat$compression_int <- FALSE
  offMat$mz_dataType <- "float"
  offMat$int_dataType <- "float"
  offMat$pixel_size_um <- clean_data$pixelSize
  
  offMat$run_data <- data.frame(x = clean_data$pos$x,
                                y = clean_data$pos$y,
                                mzLength = rep(length(clean_data$ramanShift), length(clean_data$pos$x)),
                                mzOffset = rep(16, length(clean_data$pos$x)),
                                intLength = rep(length(clean_data$ramanShift), length(clean_data$pos$x)),
                                intOffset =  16+(length(clean_data$ramanShift)*4)+(4*length(clean_data$ramanShift)*(0:(length(clean_data$pos$x) - 1)))
  )
  
  return(offMat)
}








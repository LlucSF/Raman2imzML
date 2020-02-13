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


#' Converter from WiRe(Renishaw) text format to imzML. 
#' 
#' Converts a txt files exported using WiRe 5.2 from Renishaw raman instruments and transforms it into an imzML file. The name
#' of the imzML file is going to be the same as the txt file. Only WiRe 5.2 txt files have been tested. 
#' 
#' @param txt_path path to the txt file.
#' @param imzML_path path to the folder where the imzML file is going to be stored. By default the same as the text file.
#' @param file_name name of the imzML file. By default the same as txt file.
#' 
#' @return  complete path of the imzML file.
#'
#' @export
#'
WiRe_convert <- function(txt_path, imzML_path = NULL, file_name = NULL)
{
  #Get file name and check if imzML directory exists, if not, create it.
  txt_path <- path.expand(txt_path) #path expansion to ensure proper work
  if(is.null(file_name)) 
  {
    file_name <- unlist(strsplit(basename(txt_path), split = ".txt"))
  }

  if(is.null(imzML_path)) 
  {
    imzML_path <- paste(dirname(txt_path),"/",sep = "") # Default path is the same as the txt file
  } else
    {
      imzML_path <- path.expand(imzML_path)
      if(!dir.exists(imzML_path)) 
      {
        dir.create(imzML_path) # Create folder if it does not exist.
      }  
    }

  
  #Raw data read and cleaning 
  raw_data <- as.data.frame(utils::read.table(file = txt_path, header = FALSE))
  clean_data <- wire_raw_2_clean(raw_data)
  rm(raw_data)
  
  #UUID generation, .ibd file creation and hash calculation 
  uuid <- uuid_timebased()
  hash <- write_ibd(imzML_path, file_name, clean_data, uuid)
  clean_data$hash <- hash
  clean_data$hash$uuid <- uuid
  
  #Genereting the offset matrix and the .imzML file
  offset_matrix <- clean_2_offsetMatrix(clean_data)
  rm(clean_data)
  
  if(CimzMLStore(paste(imzML_path, file_name,".imzML", sep = ""), offset_matrix))
  {
    writeLines("Successful conversion")
    return(paste(imzML_path, file_name,".imzML", sep = ""))
  }
  writeLines("Failed conversion")
  return(NULL)
}



#' Gives clean format to the raw WiRe text format.
#' 
#' @param raw_data data frame containing the raw data from the txt file.
#'
#' @return  clean data. 
#' 
wire_raw_2_clean <- function(raw_data)
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
  intensity <- matrix(ncol = band_length, nrow = number_pixels)
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




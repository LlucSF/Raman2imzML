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

#' FIVE_convert
#' 
#' Converts a txt files exported using WiRe 5.2 from Renishaw raman instruments and transforms it into an imzML file. The name
#' of the imzML file is going to be the same as the txt file. Only WiRe 5.2 txt files have been tested. 
#' 
#' @param info_txt_path path to the txt file contaiting the information of the adquisition.
#' @param table_txt_path path to the txt file contaiting all spectra as a table.
#' @param spectrum_txt_path path to the txt file contaiting one independent spectrum.
#' @param imzML_path path to the folder where the imzML file is going to be stored. By default the same as the table text file.
#' @param file_name name of the imzML file. By default the same as the table text file.
#'
#' @return  TRUE if everything is alright.
#'
#' @export
#'
FIVE_convert <- function(info_txt_path, table_txt_path, spectrum_txt_path, imzML_path = NULL, file_name = NULL)
{
  #Path work
  info_txt_path <- path.expand(info_txt_path) #path expansion to ensure proper work
  table_txt_path <- path.expand(table_txt_path)
  spectrum_txt_path <- path.expand(spectrum_txt_path)
  
  if(is.null(file_name))
  {
    file_name <- unlist(strsplit(basename(table_txt_path), split = ".txt"))
  }

  if(is.null(imzML_path))
  {
    imzML_path <- paste(dirname(table_txt_path),"/",sep = "") # Default path is the same as the txt file
  } else
    {
      imzML_path <- path.expand(imzML_path)
      if(!dir.exists(imzML_path)) 
      {
        dir.create(imzML_path) # Create folder if it does not exist.
      }  
    }
  
  #Raw data read and cleaning 
  raw_data <- as.data.frame(utils::read.table(file = table_txt_path))
  info <- as.vector(utils::read.csv2(info_txt_path, sep = "\t")[,1])
  spect <- as.data.frame(utils::read.table(file = spectrum_txt_path))
  clean_data <- five_raw_2_clean(raw_data, info, spect)
  rm(raw_data)
  rm(info)
  rm(spect)
  
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


#' five_raw_2_clean
#' 
#' @param raw_five data frame containing the raw data from the txt file.
#'
#' @return  rearranged data to fit the processing pipeline. 
#' 
five_raw_2_clean <- function(raw_data, info, spect)
{

  #Raman Shift Axis
  raman_shift <- spect[,1]
  band_length <- length(raman_shift)
  
  #Motor and relative coordenates
  number_pixels <- as.numeric(info[10]) * as.numeric(info[11])
  pixel_size <- as.numeric(info[12])
  rel_coords <- list(x = rep(1:as.numeric(info[10]), each = as.numeric(info[10])),
                     y = rep(1:as.numeric(info[11]), times = as.numeric(info[11])))
  
  motor_coords <- list(x = rep(as.numeric(info[14])*(1+(0:(as.numeric(info[10])-1))), each = as.numeric(info[10])),
                     y = rep(as.numeric(info[15])*(1+(0:(as.numeric(info[10])-1))), times = as.numeric(info[11])))
  
  
  #Intensity data filling
  intensity <- matrix(ncol = band_length, nrow = number_pixels)
  for(pixel in 1:number_pixels)
  {
    intensity[pixel,] <- raw_data[ ,pixel+1]
  }
  
  #Clean data list creation
  clean_data <- list(ramanShift = raman_shift,
                     intensity = intensity,
                     posMotors = motor_coords,
                     pos = rel_coords,
                     pixelSize = pixel_size)
  
  return(clean_data)
}




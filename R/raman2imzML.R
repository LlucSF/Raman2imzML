#########################################################################
#     Rqaman2imzML - Reinshaw's raman data in .txt format converter to 
#                    imzML using rMSI's imzML creator source code.
#
#     Copyright (C) 2020 Lluc Sementé Fernández
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

txt_path<- "/home/lluc/Documents/PhDprogram/Data/Raman/20190206/BSi_AuNP_FP_633_5%_3s_static1200_map3.txt"

raman_2_imzml <- function(txt_path, imzML_path)
{
  #Raw data read and cleaning 
  my_raw_data <- as.data.frame(utils::read.table(file = txt_path, header = FALSE))
  my_clean_data <- raw_2_clean(my_raw_data)
  rm(my_raw_data)
  
  #UUID generating and .ibd file creation
  my_uuid <- rMSI:::uuid_timebased()
  write_ibd(imzML_path,my_clean_data, my_uuid)
  
  
}

raw_2_clean <- function(raw_data)
{
  #Raman Shift Axis
  raman_shift <- union(raw_data[,3],raw_data[,3])
  band_length <- length(raman_shift)
  
  #Motor coordenates
  x <- raw_data[seq(from = 1, to = nrow(raw_data)-(band_length-1), by = band_length), 1]
  y <- raw_data[seq(from = 1, to = nrow(raw_data)-(band_length-1), by = band_length), 2]
  number_pixels <- length(x)
  motor_coords <- list(X = x, Y = y)
  
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
                     posMotors = motor_coords)
  
  return(clean_data)
}

clean_2_run <- function(clean_data)
{
  run_info <- list()
  
}

write_ibd <- function(imzML_path, clean_data, uuid)
{
  
  
}









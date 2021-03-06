% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/common.R
\name{write_ibd}
\alias{write_ibd}
\title{Read clean data, generates the binary file and computes the hash.}
\usage{
write_ibd(imzML_path, file_name, clean_data, uuid)
}
\arguments{
\item{imzML_path}{path to the folder where the imzML file is going to be stored.}

\item{file_name}{name of the txt file or a new name.(currently the converter just copies the txt file name)}

\item{clean_data}{rearranged data structure.}

\item{uuid}{uuid. This code must be shared between the imzMl file and the ibd file.}
}
\value{
List containing the sha and the md5 of the ibd file.
}
\description{
Read clean data, generates the binary file and computes the hash.
}

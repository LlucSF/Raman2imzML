# Raman2imzML

R package to convert raman data in .txt format exported from WiRe 5.2(Renishaw) and FIVE 5.1(WiTec) into the imzML data format. This package is intended to handle ONLY IMAGING DATA. This means that point sampling or lines are not supported. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

In order to install R packages from GitHub you first need to install the R package "devtools".
To do so, open an R session and type the following code in the terminal:

```R
install.packages("devtools")
```

### Installing

To install the package write the following line in your R session terminal:

```R
devtools::install_github("LlucSF/Raman2imzML")
```

### Usage

The converter currently supports two types of text file formats coming from Renishaw and WiTec. To do so, the package has two different functions: WiRe_convert() and FIVE_convert().

##### WiRe 5.2
To convert a WiRe text file into an imzML just do as follows in your R session terminal or script:
```R
#Set paths
txt_path <- "~/path/to/txt/file.txt"
imzML_path <- "~/path/to/imzML/folder/"

#Converter call
Raman2imzML::WiRe_convert(txt_path = txt_path,
                          imzML_path = imzML_path) 

#You can also just input the text file path and the imzML file is going to be created in the same folder
Raman2imzML::WiRe_convert(txt_path = txt_path)
```
##### FIVE 5.1
To transform FIVE data into an imzML you first need to export two different text files. One containing the run info and another containing the whole imaging data table. Sometimes, the raman shift axis of the data table file is wrong. To solve this the converter accepts a third text file in which, the spectrum of a single pixel is recorded which normally has the correct raman shift axis.

To convert the text files into an imzML just do as follows in your R session terminal or script:
```R
#Set paths
info_txt_path <- "~/path/to/info/txt/file.txt"
table_txt_path <- "~/path/to/table/txt/file.txt"
spectrum_txt_path <- "~/path/to/spectrum/txt/file.txt" # Only if raman shift axis in table is wrong
imzML_path <- "~/path/to/imzML/folder/"

# Converter call
Raman2imzML::FIVE_convert(info_txt_path = info_txt_path,
                          table_txt_path = table_txt_path,
                          imzML_path = imzML_path)
                          
# Converter call with spectrum file  
Raman2imzML::FIVE_convert(info_txt_path = info_txt_path,
                          table_txt_path = table_txt_path,
                          spectrum_txt_path = spectrum_txt_path,
                          imzML_path = imzML_path)
                          
#You can also just input the text file path and the imzML file is going to be created in the same folder
Raman2imzML::FIVE_convert(info_txt_path = info_txt_path,
                          table_txt_path = table_txt_path)
```
##### Output 
Two files are going to appear in the specified imzML folder (or the text file folder). A file with extenison .imzML, which contains the metadata, and a file with extension .ibd, which is a binary file containing the data itself. More information on the imzML format [here](https://ms-imaging.org/wp/imzml/).

For more information about the usage of the package check the pdf [manual](Raman2imzML_1.1.pdf) in this repository or check the help menu of the functions in the R session.

## Authors

* **Lluc Sementé** - [LlucSF](https://github.com/LlucSF)

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE.md) file for details

## Acknowledgements

* Source code for the imzML parser was extracted from the R package [rMSI](https://github.com/prafols/rMSI) of Pere Ràfols

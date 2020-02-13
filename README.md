# Raman2imzML

R package to convert raman data in .txt format exported from WiRe 5.2(Renishaw) and FIVE 5.1(WiTec) into the imzML format.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

In order to install R packages from GitHub you first need to install the R package "devtools".
To do so, open an R session and type the following code in the terminal:

```
install.packages("devtools")
```

### Installing

To install the package write the following line in your R session terminal:

```
devtools::install_github("LlucSF/Raman2imzML")
```

### Usage

The converter currently supports two types of text file formats comming from Renishaw and WiTec.

#### WiRe 5.2
To convert a WiRe txt file into an imzML just do as follows in your R session terminal or script:

```
#Linux systems
txt_path <- "~/path/to/txt/file.txt"
imzML_path <- "~/path/to/imzML/folder/"

#Converter call
Raman2imzML::WiRe_convert(txt_path, imzML_path) 

#You can also just input the txt file path and the imzML file is going to be created in the same folder
Raman2imzML::WiRe_convert(txt_path)
```

#### FIVE 5.1
To transform FIVE data into an imzML you first need to generate three diferent text files. One containing the information of a single spectrum, one containing the run info and another containing the whole imaging data table.

To convert the txt files into an imzML just do as follows in your R session terminal or script:

```
#Linux systems
info_txt_path <- "~/path/to/info/txt/file.txt"
table_txt_path <- "~/path/to/table/txt/file.txt"
spectrum_txt_path <- "~/path/to/spectrum/txt/file.txt"
imzML_path <- "~/path/to/imzML/folder/"

#Converter call
Raman2imzML::FIVE_convert(info_txt_path, table_txt_path, spectrum_txt_path, imzML_path) 

#You can also just input the txt files path and the imzML file is going to be created in the same folder as the table file
Raman2imzML::FIVE_convert(info_txt_path, table_txt_path, spectrum_txt_path)
```

Two files are going to appear in the specifed imzML folder. The .imzML, which contains the metadata, and the .ibd, which is a binary file containing the data itself. More information on the imzML format [here](https://ms-imaging.org/wp/imzml/).

## Authors

* **Lluc Sementé** - [LlucSF](https://github.com/LlucSF)

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Source code for the imzML parser was extracted from the R package [rMSI](https://github.com/prafols/rMSI) of Pere Ràfols

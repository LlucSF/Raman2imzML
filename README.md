# Raman2imzML

R package to convert Renishaw raman data in .txt format exported from WiRe 5.2 into the imzML format.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

In order to install R packages from GitHub you first need to install the R package "devtools".

```
install.packages("devtools")
```

### Installing

To install the package just write the following line in your R session terminal:

```
devtools::install_github("LlucSF/Raman2imzML")
```

### Usage

To convert a txt file into an imzML just do as follows in your R session terminal or script:

```
#Linux systems
txt_path <- "/home/user/path/to/txt/file.txt"
imzML_path <- "/home/user/path/to/imzML/folder/"

#Windows systems
txt_path <- "C:/path/to/txt/file.txt"
imzML_path <- "C:/path/to/imzML/folder/"

Raman2imzML::convert(txt_path, imzML_path)
```

Two files are going to appear in the specifed imzML folder. The .imzML, which contains the metadata, and the .ibd, which is a binary file containing the data itself. More information on the imzML format [here](https://ms-imaging.org/wp/imzml/).

## Authors

* **Lluc Sementé** - [LlucSF](https://github.com/LlucSF)

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Source code for the imzML parser was extracted from the R package [rMSI](https://github.com/prafols/rMSI) of Pere Ràfols

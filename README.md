# 🏄️ Surf Ecosystem Conservation Analysis – West Sumatra

This repository contains code and documentation for a capstone project conducted at the Bren School of Environmental Science & Management (UCSB), focused on the economic and ecological analysis of surf ecosystems in West Sumatra, Indonesia.

**Dryad archive with associated data:**  
🔗 https://datadryad.org/dataset/doi:10.5061/dryad.tb2rbp0d4

---

## 📁 How to Obtain the Data

Data required to run this code is not included in the repository. Please read the [data/README.md](data/README.md) for detailed instructions on:

- Downloading the survey dataset from Dryad
- Generating a synthetic version of the Likupang dataset via script

---

## 📜 Scripts Overview

Each script in this repository is **self-contained** and can be run independently. Key parameters are defined near the top of each script and can be adjusted for experimentation.

All scripts will generate output files in either the `figures/` directory (for plots) or the `outputs/` directory (for CSV outputs like tables or model coefficients).

### 🔧 `fit_exponential_model_likupang.R`
Fits a nonlinear exponential model to estimate the time required to complete conservation milestones based on per-capita meeting frequency. Writes a table of fitted model coefficients.

### 📊 `generate_economic_scenario_table.R`
Simulates economic outcomes under different tourism fee and crowd-reduction scenarios. Produces a summary table of net changes in value.

### 🧪 `generate_fake_likupang.R`
Creates a synthetic version of the Likupang dataset using random data that mimics the scale and structure of the original study. Intended for code transparency and reproducibility without exposing sensitive data.

### 🧼 `process_survey_data.R`
Processes raw survey results (English and Spanish versions) to extract and clean values for total trip expenditure and willingness to pay (WTP) for conservation and crowd management measures. Generates histograms, summary statistics, and box plots.

---

## 🔁 Dependencies

This project uses `R (>= 4.2.0)` and the following key packages:
- `tidyverse`
- `here`
- `readxl`
- `lubridate`
- `kableExtra`
- `webshot2` (for saving tables as images)

Use `install.packages()` or a package management tool like `renv` to install dependencies.

---

## 📬 Contact

For questions about the analysis or this codebase:

**Ryan Anderson**  
📧 rka@bren.ucsb.edu

---

## 📂 Directory Structure

```
project/
├── data/ # Contains input datasets (see data/README.md)
├── figures/ # Output plots and visualizations
├── outputs/ # Output tables (CSV format)
├── scripts/ # All main analysis scripts
│ ├── fit_exponential_model_likupang.R
│ ├── generate_economic_scenario_table.R
│ ├── generate_fake_likupang.R
│ └── process_survey_data.R
├── README.md # This file
└── data/README.md # Instructions for downloading/generating data
```

Unless otherwise noted, all code in this repository is released under the [MIT License](https://opensource.org/licenses/MIT).



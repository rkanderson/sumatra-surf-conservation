# 📁 Data Directory

This folder is intentionally left empty (except for this file).

It is used to store the data files required to reproduce the analysis in this repository. These files are **not included in the GitHub repository** due to data sharing constraints, but can be obtained or generated as described below.

---

## 📥 How to Prepare the Required Data

### 1. Download the Survey Data

You must manually download the raw survey data file from Dryad:

🔗 [https://datadryad.org/dataset/doi:10.5061/dryad.tb2rbp0d4](https://datadryad.org/dataset/doi:10.5061/dryad.tb2rbp0d4)

Save it to this `data/` directory using the following filename:

```
survey_responses_raw.xlsx

```

This file contains the raw English and Spanish responses used in our willingness-to-pay (WTP) analysis.

---

### 2. Generate the Synthetic Likupang Dataset

To maintain transparency while respecting data restrictions, we have provided a script to generate a **synthetic version** of the Likupang dataset used in our cost modeling analysis.

To generate the file:

```r
source("scripts/generate_fake_likupang.R")
```

This will create a file named `likupang_synthetic.csv` in the `data/` directory. This synthetic dataset is not intended for any other use and should not be considered a substitute for the original data.

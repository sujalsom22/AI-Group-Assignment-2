# AI Group Assignment 2 - Hacker Gang

## Team Members
| Name | Roll Number | Assigned Problem |
| :--- | :--- | :--- |
| Sujal Som (Problem 1) | B24DS032 | Problem 1 |
| Vedant Chandak | B24EC039 | |
| Tanmay Jaiswal | B24DS033 | |
| Harshit Kandpal (Problem 3) | B24CS505 | Problem 3 |

---

## Repository Structure
```
.
├── names.txt
├── README.md
├── Problem1/
│   ├── smart_home_energy_bn.py
│   ├── REPORT.md
│   ├── output.png
│   ├── network_dag.png
│   ├── mae_vs_sample_size.png
│   ├── cpt_ac_comparison.png
│   ├── comparative_results.csv
│   ├── data_500.csv
│   ├── data_5000.csv
│   └── data_20000.csv
└── Problem3/
    ├── royal_archive_access.pl
    └── output.png
```

---

## Problem 1: Smart Home Energy Consumption Analysis using Bayesian Networks

### Overview
This project models an intelligent smart-home energy management system using **Bayesian Networks**. The system predicts whether a household is likely to experience high energy consumption on a given day and explains causal factors (weather, day type, occupancy, air conditioning, and appliance load).

### Key Features & Components
1. **Part A: Expert Bayesian Network**
   - Construction of the 6-node DAG in Python (`pgmpy`, `networkx`, `matplotlib`).
   - Programmatic verification ensuring all Conditional Probability Tables (CPTs) sum to 1.
   - Exact inference for queries $Q_1$ to $Q_7$ via Variable Elimination.
   - Comprehensive explanation of **explaining away** (comparing $Q_6$ and $Q_7$).
   - Full analytical hand-calculation of $Q_1: P(E = \text{High}) = 0.580631$ matching code output.
2. **Part B: Conditional Independence Analysis**
   - Rigorous d-separation path evaluations for three target statements.
   - Identification of colliders, forks, and active paths.
   - Exact numerical verification via inference.
3. **Part C: Synthetic Data Generation**
   - Custom implementation of ancestral sampling in topological order.
   - Fixed random seed (`seed = 42`) for full reproducibility.
   - Generation and reporting of datasets of sizes 500, 5,000, and 20,000 (`data_*.csv`).
4. **Part D: Learning from Data**
   - Parameter learning via **Maximum Likelihood Estimation (MLE)** and **Bayesian Estimation** (BDeu prior with equivalent sample size $\alpha = 10$).
   - Comparison of learned AC Usage CPTs against the expert baseline.
   - Re-evaluation of inference queries $Q_1 - Q_7$ across all learned models.
5. **Part E: Comparative Analysis**
   - Comparative evaluation tables and MAE learning curves plot (`mae_vs_sample_size.png`).
   - Root-cause identification of the largest error query on small samples ($N = 500$).
   - In-depth theoretical discussion of estimator performance on small vs. large datasets.

### How to Run Problem 1

Ensure Python 3.10+ and required libraries are installed:
```bash
pip install pgmpy numpy pandas matplotlib networkx
```

Execute the end-to-end Bayesian Network analysis:
```bash
# Navigate to Problem1 directory
cd Problem1

# Run the complete analysis pipeline
python smart_home_energy_bn.py
```

### Outputs & Visualizations
- Detailed report: [Problem1/REPORT.md](Problem1/REPORT.md)
- Terminal execution output snapshot: [Problem1/output.png](Problem1/output.png)
- Bayesian Network DAG structure: [Problem1/network_dag.png](Problem1/network_dag.png)
- AC Usage CPT comparison chart: [Problem1/cpt_ac_comparison.png](Problem1/cpt_ac_comparison.png)
- Learning curves (MAE vs. Dataset Size): [Problem1/mae_vs_sample_size.png](Problem1/mae_vs_sample_size.png)
- Query results across all models: [Problem1/comparative_results.csv](Problem1/comparative_results.csv)
- Generated synthetic datasets: [Problem1/data_500.csv](Problem1/data_500.csv), [Problem1/data_5000.csv](Problem1/data_5000.csv), [Problem1/data_20000.csv](Problem1/data_20000.csv)

---

## Problem 3: Royal Archive Access Verification using Resolution Refutation

### Overview
This project models a royal archive access security policy in First-Order Predicate Logic (FOL) and verifies through Prolog and Resolution Refutation whether a given individual (`mira`) should be considered trusted (`trusted(mira)`).

### Facts & Rules
1. Every archivist who verifies a record is trusted.
2. Every trusted person who has access to a sealed record is permitted to inspect that record.
3. Anyone who inspects a record and finds a hidden mark in it verifies that record.
4. Every record stored in the royal archive is sealed.
5. `scroll_7` is stored in the royal archive.
6. Mira has access to `scroll_7`.
7. Mira inspects `scroll_7` and finds a hidden mark in it.
8. Mira is an archivist.

### Goal
Prove that: **Mira is trusted** (`trusted(mira)`) using Resolution Refutation.

---

### How to Run Problem 3

Ensure SWI-Prolog (`swipl`) is installed.

```bash
# Navigate to Problem3 directory
cd Problem3

# Run the resolution refutation proof
swipl -s royal_archive_access.pl -g "prove, halt."

# Or verify via native Prolog Horn clause inference
swipl -s royal_archive_access.pl -g "verify_trusted, halt."
```

### Output
The proof derives the empty clause `[]` demonstrating a contradiction with the negated goal `not(trusted(mira))`, confirming that `trusted(mira)` holds.  
Screenshot is saved at [Problem3/output.png](Problem3/output.png).

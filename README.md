# Perl-MODIS-Vegetation-Analysis
# MODIS Vegetation Index Processing Pipeline

## Project Overview

This project is a collection of Perl scripts that automate a complete workflow for processing MODIS (MOD09CMG) satellite imagery. The pipeline downloads daily satellite data, calculates key vegetation indices (**NDVI** and **EVI2**), and generates temporally aggregated products, including 3-day maximum composites and monthly averages.

This workflow is designed for researchers and analysts in remote sensing, environmental science, and geography who need to process large time-series of MODIS data to monitor vegetation health and environmental changes.



---

## Key Features

-   **Automated Data Download**: Fetches daily MODIS `.hdf` files from the USGS repository for a specified date range.
-   **Vegetation Index Calculation**: Computes **NDVI** (Normalized Difference Vegetation Index) and **EVI2** (Two-Band Enhanced Vegetation Index) from raw surface reflectance bands.
-   **Cloud Masking**: Utilizes the MODIS Quality Assessment (QA) band to filter out low-quality pixels affected by clouds, ensuring data integrity.
-   **Temporal Compositing**: Creates 3-day maximum value composites to reduce noise from atmospheric interference.
-   **Monthly Aggregation**: Calculates monthly average values for long-term trend analysis.
-   **Efficient Processing**: Scripts are designed to handle large volumes of binary raster data efficiently.

---

## Requirements

-   **Perl**: A working Perl installation.
-   **HDP Tool**: The `hdp` command-line utility for reading HDF4 files (part of the HDF-EOS Tools and Information Center software).
-   **Wget**: The `wget` command-line utility for downloading files.
-   **Operating System**: A Linux/Unix-based environment is recommended, as the scripts rely on shell commands.

---

## Workflow and Scripts

This project consists of a main pipeline script that executes four processing steps in order.

### 1. `01_download_modis_data.pl`

-   **Purpose**: Downloads daily MODIS (MOD09CMG) `.hdf` files for a user-defined period.
-   **Configuration**: You must edit the script to set the output directory and your NASA Earthdata login credentials.

### 2. `02_calculate_vegetation_indices.pl`

-   **Purpose**: Reads each `.hdf` file, extracts the Red and Near-Infrared (NIR) bands, applies a cloud mask using the QA band, and calculates daily NDVI and EVI2 values.
-   **Output**: Creates daily `.bin` files for both NDVI and EVI2.

### 3. `03_create_3day_composites.pl`

-   **Purpose**: Creates a new timeseries of 3-day maximum value composites. It slides a 3-day window across the daily data and, for each pixel, selects the highest valid index value. This helps to minimize cloud and aerosol effects.
-   **Output**: Creates 3-day composite `.bin` files for both NDVI and EVI2.

### 4. `04_calculate_monthly_averages.pl`

-   **Purpose**: Aggregates the daily data to produce a single average image for each month.
-   **Output**: Creates monthly average `.bin` files for both NDVI and EVI2.

### Main Script: `run_vegetation_analysis_pipeline.pl`

-   **Purpose**: An orchestrator script that calls the four processing scripts in the correct sequence. This is the primary script to execute the entire workflow.

---

## How to Run

1.  **Clone the Repository**:
    ```bash
    git clone [https://github.com/your-username/MODIS-Vegetation-Analysis.git](https://github.com/your-username/MODIS-Vegetation-Analysis.git)
    cd MODIS-Vegetation-Analysis
    ```

2.  **Organize Directories**: Create the necessary input and output directories as specified in the comments of each script. The expected structure is:
    ```
    MyProject/
    ├── INPUT/      # For downloaded .hdf files
    ├── OUTPUT/
    │   ├── NDVI/
    │   ├── EVI2/
    │   ├── Maximum_3D_NDVI/
    │   ├── Maximum_3D_EVI2/
    │   ├── NDVI_MONTHLY/
    │   └── EVI2_MONTHLY/
    └── LOG/        # For the download log file
    ```

3.  **Configure Scripts**: Open each of the `.pl` scripts and update the absolute file paths and any other necessary parameters (like date ranges or credentials) to match your environment.

4.  **Execute the Pipeline**: Run the main orchestrator script from your terminal.
    ```bash
    perl run_vegetation_analysis_pipeline.pl
    ```

The script will then execute all four steps of the analysis in order.

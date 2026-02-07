# Fantasy Football Automated ETL Pipeline

## Project Overview

This project implements an automated end-to-end ETL (Extract, Transform, Load) pipeline that ingests Fantasy Premier League (FPL) data from a public API, cleans and models it into a relational MySQL database, and incrementally stores historical per-gameweek player performance data.

The primary goal of the project is to **build a reliable, automated data foundation** that preserves historical information over time and enables meaningful analytical use cases such as performance trends, return on investment (ROI) analysis, and price movement tracking.

The pipeline is designed to be:
- **Re-runnable** (safe to execute multiple times)
- **Incremental** (only new data is appended)
- **Automated** (runs on a fixed schedule without manual intervention)

---

## Motivation

Most publicly available Fantasy Premier League data sources expose only the **current state** of players (total points, current price, minutes played). While useful, this makes it difficult to answer questions about **how performance evolves over time**.

This project addresses that limitation by:
- Storing **per-player, per-gameweek history**
- Preserving historical data instead of overwriting it
- Enabling time-based and trend-focused analysis

The result is a dataset that supports both **technical analysis** and **business-style decision making**.

---

## Data Sources

The pipeline consumes data from the official Fantasy Premier League public API:

### 1. `bootstrap-static`
Used to retrieve:
- Team metadata
- Player metadata (name, position, cost, status)
- Gameweek (event) metadata

This endpoint represents the **current state** of the season.

### 2. `element-summary/{player_id}`
Used to retrieve:
- Per-player historical gameweek performance
- Points scored per gameweek
- Minutes played per gameweek

This endpoint provides the **historical fact data** required for trend analysis.

---

## Data Model

The database follows a dimensional modeling approach, separating descriptive data from historical performance data.

### Dimension Tables

- **teams**
  - Stores team-level metadata
- **players**
  - Stores player attributes and current state
- **events**
  - Represents gameweeks and their status (finished or unfinished)

These tables describe **who** and **when**.

---

### Fact Table

- **player_gameweek_stats**
  - One row per player per gameweek
  - Stores historical performance metrics such as:
    - Points
    - Minutes played
  - Composite primary key: `(player_id, event_id)`

This table stores **what happened**, and is append-only.

---

## ETL Pipeline Flow

When the pipeline runs, the following steps occur:

1. Fetch raw JSON data from the FPL API
2. Transform and clean the data using pandas
3. Load dimension tables (`teams`, `players`, `events`) into MySQL
4. Fetch per-player gameweek history from the API
5. Transform historical data into fact-table format
6. Append new records into `player_gameweek_stats`
7. Ignore duplicate records to ensure safe re-runs

The pipeline is designed so that **historical data is never overwritten**.

---

## Incremental Updates & Historical Integrity

- Dimension tables reflect the **current state** of the season and may be updated
- Fact data is **append-only**
- Historical gameweek records are preserved permanently
- Duplicate inserts are safely ignored using a composite primary key

This design ensures that:
- Re-running the pipeline does not corrupt data
- New gameweeks are added automatically when available
- Historical trends remain accurate

---

## Analytical Objectives

This pipeline is designed to support analytical and decision-making use cases such as:

- Tracking the **return on investment (ROI)** of players by comparing points earned against player cost over time
- Analyzing **player form trends** across gameweeks
- Measuring **team-level performance trends** by averaging player points per gameweek
- Monitoring **player price changes** week-to-week
- Comparing early-season and late-season performance patterns

These analyses are only possible because historical, per-gameweek data is preserved.

---

## Automation

The pipeline is automated using **Windows Task Scheduler** and is configured to run **weekly every Friday**.

Automation ensures:
- Regular data updates without manual execution
- Continuous accumulation of historical data
- Consistency and reliability over the season

Because the pipeline is idempotent, it is safe to run on a fixed schedule.

---

## Technologies Used

- Python
- Pandas
- Requests
- MySQL
- Windows Task Scheduler
- Git & GitHub

---

## Current Status

At this stage:
- The ETL pipeline is fully implemented
- Historical gameweek data is being stored correctly
- The pipeline is automated and stable
- The dataset is ready for analytical queries and dashboarding

Future steps include SQL-based analysis and visualization using Metabase.

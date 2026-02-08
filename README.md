## Fantasy Premier League Analytics Project

## 2025/2026 Season

## Project Overview

Fantasy Premier League (FPL) managers often select players based on popularity, reputation, and club size, particularly favoring players from so-called “Big Six” teams such as Arsenal, Manchester City, Manchester United, Chelsea, Tottenham, and Liverpool. In many cases, decision-making is driven primarily by total points scored or player fame rather than efficiency and true on-pitch impact.

This approach can be misleading. A player from a smaller club may be less popular and less expensive, yet deliver strong returns on investment and high impact when on the pitch. Conversely, some high-cost players from top clubs accumulate points largely due to heavy minutes or team dominance, while providing lower value and impact relative to their cost.

This project challenges popularity-driven player selection by applying a data-driven decision framework. The analysis leverages:

- Points per 90 minutes (PP90) to measure on-pitch impact  
- Points per pound (£) spent to measure cost efficiency  
- Total points and total minutes played to ensure reliability and sustained performance  

From a business perspective, FPL players are treated as investment assets. With a fixed budget of £100 million to select 15 players, the core question becomes:

**Which players should be selected in each position to maximize total points while staying within budget and increasing overall squad value?**

---

## Data Pipeline Overview

This project follows a complete, production-style analytics pipeline:


Each stage has a clearly defined responsibility.

---

## Data Collection (Public API)

Raw Fantasy Premier League data is collected from a public FPL API.  
The API provides detailed JSON data covering:

- players  
- teams  
- fixtures  
- gameweeks  
- player-gameweek performance  

This stage focuses on:

- extracting raw data  
- handling nested JSON structures  
- preserving raw snapshots for reproducibility  

---

## Data Cleaning & Transformation (Python)

Python and Pandas are used to clean and prepare the raw API data before loading it into the database.

Key steps include:

- handling missing and zero-minute records  
- standardizing player and team identifiers  
- normalizing numeric fields  
- creating relational-ready tables  
- validating consistency across seasons and gameweeks  

Only cleaned and validated data is loaded into the database.

---

## Data Storage (MySQL)

The cleaned datasets are loaded into MySQL, forming the analytical foundation of the project.

Core tables include:

- players  
- teams  
- events (gameweeks)  
- player_gameweek_stats  

This layer provides:

- data integrity  
- repeatability  
- efficient querying for analytics  

---

## Analytical Modeling (SQL)

All core business logic is implemented using SQL views in MySQL.  
This ensures metrics are defined once, consistently, and reused across all analyses.
### SQL Models Repository

All SQL logic used to power the dashboards is stored in the `sql/` directory of this repository.

These SQL files define reusable analytical views for:
- player value rankings (Points per £)
- player impact rankings (PP90)
- minutes-based reliability filtering
- elite player classification logic

The Metabase dashboards consume these SQL views directly, ensuring consistency between
data, business logic, and visualization.


### Value (ROI)

**Points per Pound (£)**  
Measures how many FPL points a player produces for every £1 of cost.

### Impact

**Points per 90 Minutes (PP90)**  
Measures how productive a player is when on the pitch.

To avoid misleading results:

- players with very low minutes are excluded  
- minimum playing-time thresholds are applied  

### Reliability

Reliability is enforced using:

- total minutes played  
- games played  
- total points accumulated  

This ensures performance is sustained, not driven by small sample sizes.

---

## Elite Player Qualification

Players are classified as **Elite FPL Picks** if they meet all of the following:

- high value (above-average points per £)  
- high impact (above-average PP90)  
- reliable minutes and appearances  
- strong total point contribution  

This progressively narrows the player pool from hundreds of players to a high-confidence shortlist.

---

## Visualization & Dashboarding (Metabase)

The MySQL database is connected to Metabase, which serves as the visualization and decision layer.

### Page One — Player Selection Dashboard

Page One is designed to answer the primary decision question:

**Who should I buy, without overspending?**

It includes:

- Gameweek Progress Overview  
  Provides season context by showing played vs remaining gameweeks.

- Player Availability by Minutes Played  
  Highlights data reliability and sample-size distribution.

- League Benchmarks  
  Average Points per £ and Points per 90 establish comparison baselines.

- Top ROI Players by Position  
  Identifies cost-efficient players within each role.

- Top Impact Players (PP90) by Position  
  Highlights players who deliver strong returns when on the pitch.

- Elite FPL Picks  
  A final shortlist of players combining value, impact, and reliability.

- Top Scorers vs Minutes Played  
  Compares total points with playing time to distinguish efficiency from volume.

This page functions as a decision funnel, moving from context → evaluation → selection.

---
## Dashboard Preview

![Player Selection Dashboard](dashboards/player_selection_preview.png)

📄 Download full dashboard report:
[PDF](reports/metabase_player_selection_dashboard.pdf?raw=true)






---

## Design Philosophy

- Logic-first: Business logic is defined at the database level.  
- Bias-aware: Low-minute distortions are explicitly controlled.  
- Position-aware: Players are compared fairly within roles.  
- Decision-focused: Every visual supports squad selection.  
- Minimal clutter: Only metrics that drive decisions are included.  

---

## Key Takeaways

- Popularity does not equal value.  
- Cost efficiency matters more than raw points.  
- Impact must be evaluated relative to playing time.  
- Reliable minutes reduce analytical risk.  
- Strong FPL squads are built by optimizing value, not fame.  

---

## Tools Used

- Python (Pandas) — data cleaning and transformation  
- MySQL — data storage and analytical modeling  
- Metabase — visualization and dashboarding  
- Public FPL API — data source  

---

## Final Note

This project demonstrates how raw sports data can be transformed into a business-style decision support system, applying investment logic to player selection under budget constraints.

It moves beyond surface-level statistics and provides a structured framework for building competitive FPL squads.
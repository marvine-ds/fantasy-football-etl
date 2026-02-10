# Fantasy Premier League Analytics Project
## 2025/2026 Season

---

## Project Overview

Fantasy Premier League (FPL) managers often select players based on popularity, reputation, and club size, particularly favoring players from so-called “Big Six” teams such as Arsenal, Manchester City, Manchester United, Chelsea, Tottenham, and Liverpool. In many cases, decision-making is driven primarily by total points scored or player fame rather than efficiency and true on-pitch impact.

This approach can be misleading. A player from a smaller club may be less popular and less expensive, yet deliver strong returns on investment and high impact when on the pitch. Conversely, some high-cost players from top clubs accumulate points largely due to heavy minutes or team dominance, while providing lower value and impact relative to their cost.

This project challenges popularity-driven player selection by applying a data-driven decision framework. The analysis leverages:

- Points per 90 minutes (PP90) to measure on-pitch impact
- Points per pound (£) spent to measure cost efficiency
- Total points and total minutes played to ensure reliability and sustained performance

From a business perspective, FPL players are treated as investment assets. With a fixed budget of £100 million to select 15 players, the core question becomes:

Which players should be selected in each position to maximize total points while staying within budget and increasing overall squad value?

---

## Data Pipeline Overview

This project follows a complete, production-style analytics pipeline:

Data Collection → Data Cleaning → Data Storage → Analytical Modeling → Visualization

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

## Data Cleaning and Transformation (Python)

Python and Pandas are used to clean and prepare the raw API data before loading it into the database.

Key steps include:

- handling missing and zero-minute records
- standardizing player and team identifiers
- normalizing numeric fields
- creating relational-ready tables
- validating consistency across gameweeks

Only cleaned and validated data is loaded into the database.

---

## Data Storage (MySQL)

The cleaned datasets are loaded into MySQL, forming the analytical foundation of the project.

Core tables include:

- players
- teams
- events (gameweeks)
- player_gameweek_stats

This layer provides data integrity, repeatability, and efficient querying for analytics.

---

## Analytical Modeling (SQL)

All core business logic is implemented using SQL views in MySQL.  
Metrics are defined once and reused consistently across all analyses.

### SQL Models Repository

All SQL logic used to power the dashboards is stored in the `sql/` directory of this repository.

These SQL files define reusable analytical views for:

- player value rankings (Points per £)
- player impact rankings (PP90)
- minutes-based reliability filtering
- elite player classification logic
- short-term performance and trend analysis

The Metabase dashboards consume these SQL views directly, ensuring consistency between data, business logic, and visualization.

---

## Core Metrics

### Value (ROI)

Points per Pound (£)  
Measures how many FPL points a player produces for every £1 of cost.

### Impact

Points per 90 Minutes (PP90)  
Measures how productive a player is when on the pitch.

To avoid misleading results:

- players with very low minutes are excluded
- minimum playing-time thresholds are applied

### Reliability

Reliability is enforced using:

- total minutes played
- games played
- total points accumulated

This ensures performance is sustained and not driven by small sample sizes.

---

## Elite Player Qualification

Players are classified as Elite FPL Picks if they meet all of the following:

- high value (above-average points per £)
- high impact (above-average PP90)
- reliable minutes and appearances (above 1700 minutes)
- strong total point contribution (above 100 points)

This progressively narrows the player pool from hundreds of players to a high-confidence shortlist.

---

## Visualization and Dashboarding (Metabase)

The MySQL database is connected to Metabase, which serves as the visualization and decision layer.

### Page One — Player Selection and Value Analysis

Page One is designed to answer the primary decision question:

Who should I buy, without overspending?

It includes:

- Gameweek progress overview
- Player availability by minutes played
- League benchmarks (Points per £ and PP90)
- Top ROI players by position
- Top impact players (PP90) by position
- Elite FPL Picks shortlist
- Top scorers vs minutes played

This page functions as a decision funnel, moving from context to evaluation to selection.

---

### Page Two — Gameweek Trends and Performance Context

Page Two provides the contextual layer required to correctly interpret short-term performance and league-wide dynamics across gameweeks.

Fantasy Premier League scoring fluctuates significantly from one gameweek to another. Without proper context, managers may overreact to single-week outcomes or misinterpret performance changes driven by player participation rather than true impact.

This page answers questions such as:

- How high or low scoring was the most recent completed gameweek?
- Were changes in total points driven by player performance or by the number of players who featured?
- How do average points per player vary by position across gameweeks?
- Which positions contributed more on average in the latest gameweek?
- Which players delivered standout performances most recently?
- Which players are showing strong short-term form over the last five gameweeks?

Key visuals include:

- Latest gameweek total points and week-over-week change
- Player participation vs total points
- Average points per player by position (latest gameweek)
- Positional scoring trends over time
- Latest gameweek top performers by position
- Top high-value performers over the last five gameweeks
- Team-level average points per player per gameweek

All metrics exclude zero-minute players and prioritize averages where fairness across groups is required.

---

## Dashboard Report

[Download Player Selection Dashboard (PDF)](reports/Metabase_Player_Selection_Dashboard.pdf)

[Download Gameweek Trends Dashboard (PDF)](reports/Metabase_Gameweek_Trends_Dashboard.pdf)


Live Dashboard (Metabase):  
http://localhost:3000/public/dashboard/6bf5a01e-50ae-49f8-87dd-83910cd16f8c
---

## Design Philosophy

- Logic-first: business logic is defined at the database level
- Bias-aware: low-minute distortions are explicitly controlled
- Position-aware: players are compared fairly within roles
- Decision-focused: every visual supports squad selection
- Minimal clutter: only metrics that drive decisions are included

---

## Key Takeaways

- Popularity does not equal value
- Cost efficiency matters more than raw points
- Impact must be evaluated relative to playing time
- Reliable minutes reduce analytical risk
- Strong FPL squads are built by optimizing value, not fame

---

## Tools Used

- Python (Pandas) — data cleaning and transformation
- MySQL — data storage and analytical modeling
- Metabase — visualization and dashboarding
- Public FPL API — data source

---

## Final Note

This project demonstrates how raw sports data can be transformed into a structured, business-style decision-support system. By combining value, impact, reliability, and trend analysis, the dashboards help identify players who maximize returns under strict budget constraints.

Together, the two dashboards provide both actionable recommendations and the context required to interpret performance correctly throughout the season.
S
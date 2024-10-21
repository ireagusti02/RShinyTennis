## Tennis Court Finder

This is an R-shiny app that displays various aspects of tennis courts around the United States. The app allows users to intuitively find tennis clubs in their desired state. Users can filter by the number of courts, surface type, existence of a tennis "Pro-Shop," and, if data allows, by city through a search bar.

### What you will find:

*Component Files*:
- `app.R`: Contains the UI and server code for the app.
- `CitationsSources.txt`: Provides citations, links, and brief descriptions of the data sources.
- `Info.txt`: Describes the files, motivation, explanation of data, features, and relevant findings (current file).
- `Starter .csv's`: The original, uncleaned data that was used.
- `Cleaning.Rmd`: Code used to produce a cleaned `.csv` file.
- `CleanData.csv`: Cleaned data produced by `Cleaning.Rmd` and used in `app.R`.
- `state_polys.csv`: Data on state boundaries cleaned and used in `app.R`.

### For More Information

For a detailed explanation of the project's motivation, data sources, features, and relevant findings, please refer to `Info.txt`.

### Citations
- [RShiny NCAA Swim Teams App](https://shiny.posit.co/r/gallery/education/ncaa-swim-team-finder/)  
  This is the RShiny app (Swim Teams) which served as a basis for our app, Tennis Court Finder. We reduced our scope to one tab, Program Finder in the Swim Teams app, and repurposed/redesigned the functions and layout to fit our needs.
  
**Data Source:** 
  - [Data World - Tennis Courts](https://data.world/mglobel/tennis-courts)
  - [Kaggle - US Tennis Courts](https://www.kaggle.com/datasets/thedevastator/us-tennis-courts-capacity-and-amenities)  
  We originally used a .csv file from Kaggle, but found that this source had the same information as the Kaggle file as well as a column for court name, so we decided to change to this file.


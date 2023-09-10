import requests
import pyodbc

# Database connection information
server = "LAPTOP-SB9ARQUT\SQLEXPRESS"
database = "Formula One"
username = "ANEESH"
driver = "{ODBC Driver 17 for SQL Server}"

# Establish a connection to the SQL Server database
connection = pyodbc.connect(f"DRIVER={driver};SERVER={server};DATABASE={database};Trusted_Connection=yes")
cursor = connection.cursor()

# API URL for Formula One 2021 race results
api_url = "https://ergast.com/api/f1/2021/results.json?limit=500"

# Send a GET request to the API
response = requests.get(api_url)

# Check if the API request was successful (HTTP status code 200)
if response.status_code == 200:
    data = response.json()
    races = data["MRData"]["RaceTable"]["Races"]
    
    # Iterate through the race results and insert them into the database
    for race in races:
        race_name = race["raceName"]
        for result in race["Results"]:
            position = result["position"]
            driver = result["Driver"]["givenName"] + " " + result["Driver"]["familyName"]
            team = result["Constructor"]["name"]
            status = result["status"]
            
            # Execute an SQL INSERT statement to add race results to the database
            cursor.execute(f"INSERT INTO race_results (race_name, position, driver, team, status) VALUES ('{race_name}', {position}, '{driver}', '{team}', '{status}')")
    
    # Commit the changes to the database
    connection.commit()
    print("Race results uploaded successfully!")

else:
    # Print an error message if the API request was not successful
    print("Error:", response.status_code)

# Close the cursor and database connection
cursor.close()
connection.close()
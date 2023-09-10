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

# Loop through race numbers from 1 to 22
for race_number in range(1, 23):
    # API URL for Formula One 2021 race lap times
    api_url = f"https://ergast.com/api/f1/2021/{race_number}/laps.json?limit=2000"
    
    # Send a GET request to the API
    response = requests.get(api_url)

    # Check if the API request was successful (HTTP status code 200)
    if response.status_code == 200:
        data = response.json()
        races = data["MRData"]["RaceTable"]["Races"]
        
        # Iterate through the race lap data and insert it into the database
        for race in races:
            race_name = race["raceName"]
            laps = race["Laps"]
            for lap in laps:
                lap_number = lap["number"]
                for result in lap["Timings"]:
                    position = result["position"]
                    driver = result["driverId"]
                    lap_time = result["time"]
                    
                    # Execute an SQL INSERT statement to add lap times to the database
                    cursor.execute(f"INSERT INTO lap_times (race_name, lap_number, position, driver, lap_time) VALUES ('{race_name}', {lap_number}, {position}, '{driver}', '{lap_time}')")

        # Commit the changes to the database
        connection.commit()
        print(f"Race {race_number} lap times uploaded successfully!")

    else:
        # Print an error message if the API request was not successful
        print("Error:", response.status_code)

# Close the cursor and database connection
cursor.close()
connection.close()
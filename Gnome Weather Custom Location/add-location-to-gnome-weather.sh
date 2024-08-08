#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Check if GNOME Weather is installed (system or Flatpak)
if command -v gnome-weather &>/dev/null; then
	system=1
elif flatpak list | grep -q org.gnome.Weather; then
	flatpak=1
else
	echo -e "${RED}GNOME Weather isn't installed${RESET}"
	exit 1
fi

# Get location query from arguments or prompt the user
if [[ -n "$*" ]]; then
	query="$*"
else
	echo -e "${CYAN}Type the name of the location you want to add to GNOME Weather:${RESET}"
	read -p "> " query
fi

# URL encode the query to handle special characters
query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")

# Fetch location data
request=$(curl -s "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=10")

# Check if the request was successful
if [[ -z "$request" ]]; then
	echo -e "${RED}Failed to retrieve location data. Please check your internet connection.${RESET}"
	exit 1
fi

# Check if any locations were found
if [[ $request == "[]" ]]; then
	echo -e "${YELLOW}No locations found, consider refining your search terms.${RESET}"
	exit 1
fi

# Parse and display the list of locations
locations=()
while IFS= read -r location; do
	locations+=("$location")
done < <(echo "$request" | jq -r '.[].display_name' 2>/dev/null)

# Check if jq successfully parsed the locations
if [[ ${#locations[@]} -eq 0 ]]; then
	echo -e "${RED}Failed to parse location data. Please try a different query.${RESET}"
	exit 1
fi

echo -e "${CYAN}Select a location to add:${RESET}"
for i in "${!locations[@]}"; do
	printf "${YELLOW}%d)${RESET} %s\n" $((i+1)) "${locations[$i]}"
done

# Prompt user to select a location
read -p "Enter the number of the location you want to add: " selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || ((selection < 1 || selection > ${#locations[@]})); then
	echo -e "${RED}Invalid selection.${RESET}"
	exit 1
fi

# Extract selected location details
selected_location=$(echo "$request" | jq ".[$((selection-1))]")
name=$(echo "$selected_location" | jq -r '.display_name')
lat=$(echo "$selected_location" | jq -r '.lat')
lon=$(echo "$selected_location" | jq -r '.lon')

# Convert latitude and longitude to radians
lat_rad=$(echo "$lat * 3.141592654 / 180" | bc -l)
lon_rad=$(echo "$lon * 3.141592654 / 180" | bc -l)

# Get current GNOME Weather locations
if [[ $system == 1 ]]; then
	locations=$(gsettings get org.gnome.Weather locations)
else
	locations=$(flatpak run --command=gsettings org.gnome.Weather get org.gnome.Weather locations)
fi

# Build the new location entry
location="<(uint32 2, <('$name', '', false, [($lat_rad, $lon_rad)], @a(dd) [])>)>"

# Update GNOME Weather locations
if [[ $locations != "@av []" ]]; then
	locations=$(echo "$locations" | sed "s|>]|>, $location]|")
else
	locations="[$location]"
fi

# Set the new locations
if [[ $system == 1 ]]; then
	gsettings set org.gnome.Weather locations "$locations"
else
	flatpak run --command=gsettings org.gnome.Weather set org.gnome.Weather locations "$locations"
fi

echo -e "${GREEN}Location added: $name${RESET}"

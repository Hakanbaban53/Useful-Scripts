# GNOME Weather Location Adder

This script allows you to add a location to GNOME Weather using OpenStreetMap data. 
It supports both the system-installed and Flatpak versions of GNOME Weather.

## Features

- **Query Locations:** Search for locations by name.
- **Select from Multiple Results:** Choose the correct location from a list of results.
- **Add Locations:** Add the selected location to GNOME Weather.
- **Handles Special Characters:** Supports queries with special characters.

## Prerequisites

- **GNOME Weather** (either system-installed or Flatpak version).
- **curl:** Used to fetch location data from OpenStreetMap.
- **jq:** Used to parse JSON responses.
- **bc:** Used for mathematical calculations (latitude and longitude conversion).

## Installation

1. **Install dependencies:**
   ```bash
   # Ubuntu
   sudo apt-get install curl jq bc
   # Arch
   sudo pacman -S curl jq bc
   # Fedora
   Sudo dnf install curl jq bc
   ```

2. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/Hakanbaban53/Useful-Scripts/main/Gnome%20Weather%20Custom%20Location/add-location-to-gnome-weather.sh
   sh -O gnome-weather-location-adder.sh
   chmod +x gnome-weather-location-adder.sh
   ```

## Usage

Run the script and follow the prompts:

```bash
./gnome-weather-location-adder.sh "Location Name"
```

- If you don't provide a location as an argument, the script will prompt you to enter one.
- The script will display a list of matching locations. You can select the desired location by entering its corresponding number.
- The selected location will be added to GNOME Weather.

## Example

```bash
./gnome-weather-location-adder.sh "Çimenli"
```

Output:

```
Type the name of the location you want to add to GNOME Weather:
> Çimenli
Select a location to add:
1) Çimenli, Trabzon, Karadeniz Bölgesi, Türkiye
2) Çimenli, Samsun, Karadeniz Bölgesi, Türkiye
Enter the number of the location you want to add: 1
Location added: Çimenli, Trabzon, Karadeniz Bölgesi, Türkiye
```

## License

This script is open-source and distributed under the MIT License.

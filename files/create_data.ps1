# Function to generate random text (for names, etc.) - Improved
function Get-RandomText {
    param(
        [int]$minLength = 5,
        [int]$maxLength = 15
    )
    $length = Get-Random -Minimum $minLength -Maximum $maxLength
    $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" # Removed numbers
    $randomText = ""
    for ($i = 0; $i -lt $length; $i++) {
        $randomIndex = Get-Random -Maximum ($characters.Length - 1)
        $randomText += $characters[$randomIndex]
    }
    return $randomText
}

# Function to generate random phone numbers
function Get-RandomPhone {
    $areaCode = Get-Random -Minimum 200 -Maximum 999
    $exchange = Get-Random -Minimum 200 -Maximum 999
    $subscriber = Get-Random -Minimum 0000 -Maximum 9999
    return "$areaCode-$exchange-$subscriber" # Format: XXX-XXX-XXXX
}


# Function to generate random email addresses
function Get-RandomEmail {
    $name = Get-RandomText -minLength 8 -maxLength 12 # Realistic name part
    $domains = @("gmail.com", "yahoo.com", "outlook.com", "example.com")
    $domain = $domains | Get-Random
    return "$name@$domain"
}

# Function to generate random addresses
function Get-RandomAddress {
    $streetNumber = Get-Random -Minimum 100 -Maximum 999
    $streetName = Get-RandomText -minLength 8 -maxLength 15
    $streetTypes = @("St", "Rd", "Ave", "Blvd", "Dr")
    $streetType = $streetTypes | Get-Random
    return "$streetNumber $streetName $streetType"
}

# Function to generate random postal codes (5 digits)
function Get-RandomPostalZip {
    return Get-Random -Minimum 10000 -Maximum 99999
}

# Function to generate random regions (you'll likely want to customize this)
function Get-RandomRegion {
  $regions = @("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming")
  return $regions | Get-Random
}


# Generate Data
$data = @()
for ($i = 1; $i -le 1000; $i++) {
    # Create $row using [PSCustomObject]
    $row = [PSCustomObject]@{
        name = (Get-RandomText -minLength 5 -maxLength 10) # Shorter names
        phone = Get-RandomPhone
        email = Get-RandomEmail
        address = Get-RandomAddress
        postalZip = Get-RandomPostalZip
        region = Get-RandomRegion
        country = (Get-RandomText -minLength 5 -maxLength 10) # Random countries (customize as needed)
    }
    $data += $row
}

# Export to CSV (using Select-Object)
$data | Select-Object name,phone,email,address,postalZip,region,country | Export-Csv -Path "employees_contacts
.csv" -NoTypeInformation

Write-Host "CSV file 'data.csv' created with 1000 rows."
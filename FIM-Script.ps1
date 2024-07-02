Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new baseline?" 
Write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host -Promt "Please enter 'A' or 'B'"

Function Calculate-file-hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}


function Erase-baseline-if-already-exists() {
    $baselineExists = Test-Path -Path C:\Users\Anthony\OneDrive\Desktop\FIM\Files\baseline.txt

    if ($baselineExists) {
        # Delete it
        Remove-Item -Path C:\Users\Anthony\OneDrive\Desktop\FIM\Files\baseline.txt
        Write-Host "baseline already exists"
        }
}

if ($response -eq "A". ToUpper()) {
    #Delete baseline.txt if it already exists
    Erase-baseline-if-already-exists

    # calculate Hash from the target files and store in baseline.txt
   
    # colllect all files in the target folder
    $files = Get-ChildItem -Path C:\Users\Anthony\OneDrive\Desktop\FIM\Files 
  
    
     # For each file, calculate the hash, and write to baseline.txt
    foreach ($f in $files) { 
    Write-Host "Calculating Hash"
      $hash = Calculate-file-hash $f.Fullname 
      "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath C:\Users\Anthony\OneDrive\Desktop\FIM\Files\baseline.txt -Append
    }


} elseif ($response -eq "B". ToUpper()) {

    $fileHashDictionary = @{}
  
    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathsAndHashes = Get-Content -Path C:\Users\Anthony\OneDrive\Desktop\FIM\Files\baseline.txt
    
    foreach ($f in $filePathsAndHashes) {
            $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
        }

    # Begin (continuously) monitoring files with saved baseline
    while ($true) {
        Start-Sleep -Seconds 1
        $files = Get-ChildItem -Path C:\Users\Anthony\OneDrive\Desktop\FIM\Files
    
  
     # For each file, calculate the hash, and write to baseline.txt
     foreach ($f in $files) {
         $hash = Calculate-file-hash $f.Fullname 
         #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\Baseline.txt -Append

        # Notify if a new file has been created 
         if ($fileHashDictionary[$hash.Path] -eq $null) {
            # A new file has been created!
            Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
        }
        else {

        # Notify if a new file has been changed 
        if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
            # The file has not changed
            }
            else {
                # File file has been compromised!. notify the user
                Write-Host "$($hash.Path) has been cganged!!" -ForegroundColor yellow
      }
  
    }
    foreach ($key in $fileHashDictionary.keys) {
        $baselinefilestillExists = Test-Path -Path $key
        if (-not $baselinefilestillExists) {
            # one of the baseline files must have been deleted, notify the user
            Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
      }
    }
}
}
}



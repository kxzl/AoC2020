﻿
$liste = Get-Content -Path ".\D19_Input\Input.txt" -Raw

$nl = [System.Environment]::NewLine
$liste = $liste -split "$nl$nl"

$regler_arr = $liste[0]
$input = $liste[1]

#hashtables 4 life
$regler = @{}

# populer hashtabell med reglene og definer "a" og "b" regler som regex
foreach ($regel in $regler_arr.Split("`n")) {
    
    $reg_split = $regel.Split(":")

    $nr = ($reg_split[0]).trimend().trimstart().replace('"',"")
    $reg = ($reg_split[1]).trimend().trimstart().replace('"',"")

    #if (($reg -eq "a") -or ($reg -eq "b")) {
    #    $reg = [regex]$reg
    #}
    
    $regler.Add($nr,$reg)
}


[array]$key_list = @()
$ny_regler = $regler.Clone()
$rx_tall_idx = [regex]"\d+"
$not_matched = $true


$count=0
$forrige_svar = -1


:outer while ($not_matched) {
    :in1 foreach ($key in $regler.Keys) { 
        
        if ($rx_tall_idx.Match($regler.$key).success -eq $true) {
            
            $value_array = $regler.$key.Split(" ")
            for ($i=0; $i -lt $value_array.count; $i++) {            
                
                $tegn = $value_array[$i]

                if ($rx_tall_idx.Match($tegn).success -eq $true) {
                    $value_array[$i] = $rx_tall_idx.Replace($tegn,"("+$regler."$($rx_tall_idx.Match($tegn).value)"+")") 
                }

            }

            $ny_regler.$key = ($value_array -join " ")
            
        }

    }

    
    :in2 foreach ($key in $regler.Keys) { 
        if (-not($regler.$key -eq $ny_regler.$key)) {
            $regler = $ny_regler.Clone()
            $count++

            if($counter -gt 10) {
                break outer
            }

            #continue outer
            $rx_rule = ("\b"+$($ny_regler."0").Replace(" ","")+"\b")
            $Svar = [regex]::Matches(($input.Split("`n")),$rx_rule).count
            Write-Host "Count: $count"
            Write-Host "Foreløpig Svar: $Svar" -f Cyan
            if(($Svar -eq $forrige_svar) -and $Svar -ne 0) {
                break outer
            }

            $forrige_svar = $Svar
            continue outer
        }
    }

    $not_matched = $false


}

#$regler = $ny_regler.Clone()

Write-Host "Svar: $Svar" -f Magenta



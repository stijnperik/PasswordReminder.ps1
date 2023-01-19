###################################
# Passwordreminder
###################################
#
# Let op : dit dient altijd als administrator te worden gestart (powershell, ISE en als taak)
#          anders worden diverse parameters niet gelezen en is het script niet functioneel
#
###################################
# Benodigd
###################################
#
# Logdirectory zoals benoemd in $LogPath
# 
###################################
# Aan te passen
###################################
#
# Rubriek (aangegeven met [Rubrieknaam])
#
# [Algemeen]
#
#        Searchbase       - Waar staan de te onderzoeken gebruikers in het AD
#        maxpwddays       - Maximale wachtwoordleeftijd zoals in policy benoemd
#        pwdexp1          - Aantal dagen voor verloop voor eerste waarschuwing
#        pwdexp2          - Aantal dagen voor verloop voor tweede waarschuwing
#        pwdexp3          - Aantal dagen voor verloop voor derde waarschuwing (hierna elke dag)
#        SmtpAddress      - adres van de mailserver waar de mail naartoe gestuurd wordt.
#	     MailSender       - adres van de afzender van de te versturen mail.
#        Contacts         - Contactpersonen waarnaar verwezen wordt voor hulp en ondersteuning
#
# [LogPath]
#
#        LogPath    - Locatie van de logfile
#                     (wordt iedere run opgeslagen met de datum waarop deze gemaakt is)
#
# [Debug]
#        
#        Debug = $True / $False
#                   - $True levert extra informatie in powershell op (ise en console)
#
# [ExtraRecipients]
#
#                   - Hier kunnen extra ontvangers van de mail worden opgegeven
#
###################################
# Parameters
###################################
#
# [Algemeen]
#
$SearchBase = "ou=, ou=, dc=, dc="
$maxpwddays = 90
$pwdexp1= 10
$pwdexp2 = 5
$pwdexp3 =  1
$SmtpAddress = ""
$mailSender = ""
$Contacts = "" 
#
$date_expire = ""
$Currenttime = (Get-Date).Ticks
#
# [Debug]
#
$Debug = $False
#
$users = get-aduser -searchbase $SearchBase -filter * -Properties *
#
# Naam en locatie logfile
#
$Logentry = ""
$Date = Get-Date -format "dd-MM-yyyy"
$logfilename = "SendPWReminderLog-"+$Date+".txt"
$LogPath = "c:\scripts\logging\PasswordReminder"
$logFile = $logPath+"\"+$logfilename
#
###################################
# Function  to write enttry in logfile
###################################
#
Function activitylog()
{
Add-Content $logfile $logentry
}
#
###################################
# Function to send HTML email to each user
###################################
#
function send_email
{
if ($Debug)
    {
    Write-Host "Gebruiker                  : "$user.displayname
    Write-Host "Wachtwoord verloopt in     : "$DaysRemaining" dagen"
    Write-Host "PasswordReminder           : "$Pwdreminder
    Write-Host "Gebruiker actief (enabled) : "$user.enabled
    Write-Host "Wachtwoord verloopt nooit  : "$user.PasswordNeverExpires
  }  
 $name = $user.name
 $today = Get-Date
 $today = $today.ToString("dddd (dd-MMMM-yyyy)")
 $date_expire = [DateTime]::Now.AddDays($daysremaining)
 $date_expire = $date_expire.ToString("dddd dd MMMM yyyy")
 $SmtpClient = new-object system.net.mail.smtpClient
 $Smtpclient.Host = $SmtpAddress 
 $mailmessage = New-Object system.net.mail.mailmessage 
 $mailmessage.from = $mailSender 
 $mailmessage.Subject = "$name, Binnenkort verloopt je wachtwoord!!!"
 $mailmessage.IsBodyHtml = $true
 $mailmessage.Priority = "High"
 $email = $user.EmailAddress
 if ($Debug)
        {
        Write-Host "E-mailadres (gebruiker)    : "$user.Emailaddress
        Write-Host "MailServer                 : "$SMTPclient.Host
        Write-Host "Wachtwoord verloopt op     : "$date_expire
        Write-Host "Huidige datum              : "$today
        }
 if (!$user.EmailAddress -eq "")
    {
    $mailmessage.To.add($email)
#
# [ExtraRecipients]
#
    $mailmessage.To.Add("")
    }
    else
    {
    $Logentry = $user.name+" heeft geen E-Mail adres"
    activitylog
    }
 #
 if ($DaysRemaining -le 0)
    { 
    $Verloopstring = "<font color=red><strong>is verlopen</strong></font>"
    }
    else
    {
    $Verloopstring1 = "verloopt in "
    $VerloopString2 = "<font color=red><strong>$daysremaining</strong></font>"
    $Verloopstring3 = " dagen  op <strong>$date_expire</strong><br /><br />"
    $VerloopString = $VerloopString1+$VerloopString2+$VerloopString3
    }
 $mailmessage.Body = @"
<h5><font face=Arial>Beste $name, </font></h5>
<h5><font face=Arial>Je wachtwoord  $Verloopstring.<br />
Je wachtwoord is noodzakelijk voor toegang tot je Computer en Email.<br /<br />
Om je wachtwoord te wijzigen, druk op CTRL-ALT-END en kies Wachtwoord wijzigen.<br /><br />
Een geldig wachtwoord moet minimaal 7 karakters lang zijn en karakters bevatten uit 3 van de 4 onderstaande groepen:<br /><br />
    hoofdletters (A-Z)<br />
    kleine letters (a-z)<br />
    nummers (0-9)<br />
    symbolen (!"£$%^&*)<br /><br />
 Gegenereerd op : $today<br /><br />
_____________ <br />
<br /></font></h5>
"@
#

 if ($Debug)
        {
        Write-Host "Mailbody                   : "$mailmessage.body
        Write-Host "Verstuurd naar             : "$mailmessage.To
        Write-Host "Afzenderadres              : "$mailmessage.From
        }
#
# $Logentry = $mailmessage.Body
# activitylog
# $mailmessage.body
if (!$user.EmailAddress -eq "")
    {
 $smtpclient.Send($mailmessage)
    }
}
#
###################################
# Main Program
###################################
#
$Logentry = "******************************"
activitylog
$Logentry = "*  Datum : "+$Date
activitylog
$Logentry = "******************************"
activitylog
$Logentry = ""
activitylog
#
$userlist = @()
#
# Telling van aantal gevonden gebruikers en aantal gebruikers welke een mail hebben gehad.
#
# Mocht debug ingeschakeld staan, dan worden deze ook in de powershell consoles getoond.
#
$totalusers = $users.count
$sendusers = 0

foreach ($user in $users)
{
if (($user.enabled)  -and (!$user.PasswordNeverExpires))
    {
    $user.name
if ($Debug)
    {
    $LogEntry = $user.name+" remaining :"+$DaysRemaining+" Level : "+$pwdreminder+" Ouderdom : "+$Daysold
    activitylog
    }
    $DaysOld = [int]($Currenttime-(($user.passwordlastset))).Days
    $DaysRemaining = $maxpwddays - $Daysold  
     $pwdreminder = 0
			if ($pwdexp2 -gt $Daysremaining)
			{
			$pwdreminder = 5
			}
			if ($pwdexp3 -gt $Daysremaining)
			{
			$pwdreminder = 10
			}
			if ($Daysremaining -eq 4)
			{
			$pwdreminder = 4
			}
			if ($Daysremaining -eq 3)
			{
			$pwdreminder = 3
			}
			if ($Daysremaining -eq 2)
			{
			$pwdreminder = 2
			}
			if ($Daysremaining -eq 1)
			{
			$pwdreminder = 1
			}

    $String = $user.name+" remaining :"+$DaysRemaining+" Level : "+$pwdreminder+" Ouderdom : "+$Daysold 
if ($DEBUG)
    {
    $String
    }
#
#
    if (!$pwdreminder -eq 0)
			{
            $sendusers = $sendusers+1
           $Logentry = "Er is een mail verstuurd naar : "+$String
           activitylog
#
            send_email
			}
    }



 }
            $Logentry = "##############################"
            activitylog
            $Logentry = "Totaal aantal gebruikers : "+$totalusers
            activitylog
            $Logentry = "Aantal verzonden maIls   : "+$sendusers
            activitylog
            $Logentry = "##############################"
            activitylog

if ($DEBUG)
    {
    Write-Host "Totaal aantal gebruikers : "$totalusers
    Write-Host "Aantal verzonden mails    : "$sendusers
    }
#
###################################
# End of Program
###################################
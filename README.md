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

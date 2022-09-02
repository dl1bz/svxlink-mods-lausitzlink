namespace eval ReflectorLogic {

# initialisiere Variablen
variable myRufz none
variable last_rptr none

#
# Executed on talker stop
#
#   tg        -- The talk group
#   callsign  -- The callsign of the talker node
#
proc talker_stop {tg callsign} {

global langdir

variable last_rptr
variable myRufz

# wir kontrollieren mal den Pfad ob korrekt
puts "DEBUG: $langdir"

# Modifikation zur Ansage der Reflektorquellen als QTH in der TG7
if {($callsign != $myRufz) && ($tg == 7) && ($callsign != $last_rptr)} {
   if [file exists "$langdir/Own/$callsign.wav"] {
     playMsg "Own" $callsign
     playSilence 100
   } else {
     puts "$langdir/Own/$callsign.wav nicht vorhanden !"
   }
}

if {($myRufz != $callsign) && ($tg == 7)} {
   set last_rptr $callsign
}
   puts "DEBUG: myRufz $myRufz"
   puts "DEBUG: Last RPTR: $last_rptr"
}

#
# Executed when a TG selection has timed out
#
#   new_tg -- Always 0
#   old_tg -- The talk group that was active
#
proc tg_selection_timeout {new_tg old_tg} {
  #puts "### tg_selection_timeout"
  # bei Wechsel zu TG0 NICHT den TX hochtasten wie es eigentlich im Original gemacht wird

  variable last_rptr
  variable myRufz

  if {$new_tg == 0} {
    # DO2HN patch
    set last_rptr $myRufz
    puts "DEBUG: REFL CONN IDLE > switch to TG #0"
  } elseif {$old_tg != 0} {
    playSilence 100
    playTone 880 200 50
    playTone 659 200 50
    playTone 440 200 50
    playSilence 100
  }
}

if [info exists ::Logic::CFG_CALLSIGN] {
  set myRufz $::Logic::CFG_CALLSIGN
  set last_rptr $myRufz
}

# end of namespace
}

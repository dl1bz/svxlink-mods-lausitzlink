namespace eval ReflectorLogic {

# Setze eigenes Rufzeichen aus der svxlink.conf als Startvariable
variable myRufz DB0SPB
variable last_rptr $myRufz

#
# Executed on talker stop
#
#   tg        -- The talk group
#   callsign  -- The callsign of the talker node
#
proc talker_stop {tg callsign} {

variable last_rptr
variable myRufz
global langdir

# wir kontrollieren mal den Pfad ob korrekt
puts "DEBUG: $langdir"

# Modifikation zur Ansage der Reflektorquellen als QTH in der TG7
if {($callsign != $::Logic::CFG_CALLSIGN) && ($tg == 7) && ($callsign != $last_rptr)} {
   if [file exists "$langdir/Own/$callsign.wav"] {
     playMsg "Own" $callsign
     playSilence 100
   } else {
     puts "$langdir/Own/$callsign.wav nicht vorhanden !"
   }
}

if {($::Logic::CFG_CALLSIGN != $callsign) && ($tg == 7)} {
   set last_rptr $callsign
}
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

# end of namespace
}

namespace eval EchoLink {

#
# Check if this module is loaded in the current logic core
#
if {![info exists CFG_ID]} {
  return;
}

proc remote_greeting {call} {
  global langdir
  variable module_name

# eigene Ansage bei Echolink-Connect
# es muss unter /usr/share/svxlink/sounds/de_DE/EchoLink eine Datei mit owncall.wav vorhanden sein

  if [file exists "$langdir/$module_name/owncall.wav"] {
    playSilence 1000;
    playMsg "greeting";
    playSilence 250;
    playMsg "owncall";
  } else {
    puts "$langdir/$module_name/owncall.wav nicht vorhanden."
  }
}

# end of namespace
}

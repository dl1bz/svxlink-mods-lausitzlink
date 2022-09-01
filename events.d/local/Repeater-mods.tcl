namespace eval RepeaterLogic {

# andere Sprachausgaben wenn Testbetrieb = 1
variable testbetrieb 1

proc repeater_up {reason} {
  global mycall;
  global active_module;
  global report_ctcss;
  global langdir;
  variable repeater_is_up;
  variable testbetrieb;

  set repeater_is_up 1;

  if {($reason != "SQL_OPEN") && ($reason != "CTCSS_OPEN") &&
      ($reason != "SQL_RPT_REOPEN")} {
    set now [clock seconds];
    if {$now-$Logic::prev_ident < $Logic::min_time_between_ident} {
      return;
    }
    set Logic::prev_ident $now;

    if {!$testbetrieb} {
      spellWord $mycall;
      playMsg "Core" "repeater";
      playSilence 250;
    } else {
      if [file exist "$langdir/Own/testmode.wav"] {
        playMsg "Own" "testmode";
      }
    }

    if {$report_ctcss > 0} {
       playSilence 100;
       playMsg "Own" "ctcss";
       playFrequency $report_ctcss;
    }
    playSilence 250;
   
    if {$active_module != ""} {
      playMsg "Core" "active_module";
      playMsg $active_module "name";
    }
    puts "DEBUG: execute Proc RPTR_IS_UP"
  }
}

proc repeater_down {reason} {
  global mycall;
  global langdir;
  variable repeater_is_up;
  variable testbetrieb

  set repeater_is_up 0;

  if {$reason == "SQL_FLAP_SUP"} {
    playSilence 500;
    playMsg "Core" "interference";
    playSilence 500;
    return;
  }

  set now [clock seconds];
  if {$now-$Logic::prev_ident < $Logic::min_time_between_ident} {
    playTone 400 900 50
    playSilence 100
    playTone 360 900 50
    playSilence 500
    return;
  }
  set Logic::prev_ident $now;

  if {!$testbetrieb} {
    spellWord $mycall;
    playMsg "Core" "repeater";
    playSilence 250;
  } else {
  if [file exist "$langdir/Own/testmode.wav"] {
    playMsg "Own" "testmode";
    playSilence 250;
  }
  }
  #playMsg "../extra-sounds" "shutdown";
}

#
# Executed if the repeater opens but the squelch never opens again.
# This is probably someone who opens the repeater but do not identify.
#
proc identify_nag {} {

  variable repeater_is_up;

  puts "DEBUG: execute Proc PLS_IDFY"

  # puts [lsort [info globals]]
  # puts [lsort [info vars]]

  # puts "DEBUG: $::Logic::sql_rx_id"
  # puts "DEBUG: UP? : $repeater_is_up"

  if {$repeater_is_up} {
    playSilence 500;
    playMsg "Core" "please_identify";
    playSilence 500;
  }
}

# end of namespace
}

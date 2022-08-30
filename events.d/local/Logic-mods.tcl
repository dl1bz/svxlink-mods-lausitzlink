namespace eval Logic {

variable is_rf 0;
variable testbetrieb 0;

# sende k als Rogerbeep wenn HF
proc squelch_open {rx_id is_open} {
  variable sql_rx_id;
  variable is_rf;
  set sql_rx_id $rx_id;

  # puts [lsort [info vars]]
  # puts [lsort [info globals]]

  if {!$is_open} {
    # playSilence 50;
    playTone 1000 200 150; # Ton 1000Hz 200% Amplitude 150ms lang
    playSilence 50;
    playTone 1000 200 75;
    playSilence 50;
    playTone 1000 200 150;
    set is_rf 1;
  }
}

# sende i als Rogerbeep wenn NICHT via HF
proc send_rgr_sound {} {
  variable is_rf;
  variable sql_rx_id;

  puts "DEBUG: RF?: $is_rf"
  puts "DEBUG: RX-ID: $sql_rx_id"

  # puts [lsort [info vars]]
  # puts [lsort [info globals]]

  if {!$is_rf} {
    if {$sql_rx_id == "R"} {
    # "k" as beep if receiver_id R (local rf receiver)
    playTone 1000 200 150; # Ton 1000Hz 200% Amplitude 150ms lang
    playSilence 50;
    playTone 1000 200 75;
    playSilence 50;
    playTone 1000 200 150;
    } else {
    # "i" as beep for other sources
    playTone 880 150 50;
    playSilence 50;
    playTone 880 150 50;
  }
  }
  set is_rf 0;
  set sql_rx_id "?";
}

#
# Executed when a short identification should be sent
#   hour    - The hour on which this identification occur
#   minute  - The minute on which this identification occur
#
proc send_short_ident {{hour -1} {minute -1}} {
  global mycall;
  variable CFG_TYPE;
  variable short_announce_file
  variable short_announce_enable
  variable short_voice_id_enable
  variable short_cw_id_enable
  variable testbetrieb

  # Play voice id if enabled
  if {$short_voice_id_enable} {
    puts "Playing short voice ID"
    spellWord $mycall;
    if {$CFG_TYPE == "Repeater"} {
      playMsg "Core" "repeater";
    }
    playSilence 500;
  }
  # Play announcement file if enabled
  if {$short_announce_enable} {
    puts "Playing short announce"
    if [file exist "$short_announce_file"] {
      playFile "$short_announce_file"
      playSilence 500
    }
  }

  # Play CW id if enabled
  if {$short_cw_id_enable} {
    puts "Playing short CW ID"
    if {$CFG_TYPE == "Repeater"} {
      set call "$mycall"
      # Repeater Testbetrieb ? (0 = nein /1 = ja)
      set testbetrieb 1
      playSilence 200;
      CW::play $call
        # sende in CW nach dem Repeaterrufzeichen noch TEST wenn der Repeater im Testbetrieb ist
        if {$testbetrieb} {
         playSilence 200;
         CW::play "test"
        }
    } else {
      playSilence 200;
      CW::play $mycall
    }
    playSilence 500;
  }
}


# Die folgenden 4 Prozeduren erzeugen eine Ansage wenn der Reflektor getrennt/verbunden/aktiv/nicht aktiv ist
# Es wird nach einer Datei <LINKIDENTIFIER>.wav gesucht, hier ist das z.B. LL.wav --> siehe svxlink.conf
# ansonsten wird der Linkidentifier einfach buchstabiert ausgegeben (so im Original)
#
# Bsp in der /etc/svxlink/svxlink.conf :
# [ReflectorLink]
# CONNECT_LOGICS=RepeaterLogic:94:LL,ReflectorLogic
# 94:LL bedeutet, LL ist der Link-Identifier und den geben wir als LL.wav aus, sonst wird der einfach nur buchstabiert

#
# Executed when a link to another logic core is activated.
#   name  - The name of the link
#
proc activating_link {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "activating_link_to";
    if {$name == "LL"} {
      playMsg "Own" $name
    } else {
      spellWord $name;
    }
  }
}


#
# Executed when a link to another logic core is deactivated.
#   name  - The name of the link
#
proc deactivating_link {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "deactivating_link_to";
    if {$name == "LL"} {
      playMsg "Own" $name
    } else {
      spellWord $name;
    }
  }
}

#
# Executed when trying to deactivate a link to another logic core but the
# link is not currently active.
#   name  - The name of the link
#
proc link_not_active {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "link_not_active_to";
    if {$name == "LL"} {
      playMsg "Own" $name
    } else {
      spellWord $name;
    }
  }
}


#
# Executed when trying to activate a link to another logic core but the
# link is already active.
#   name  - The name of the link
#
proc link_already_active {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "link_already_active_to";
    if {$name == "LL"} {
      playMsg "Own" $name
    } else {
      spellWord $name;
    }
  }
}

# end of namespace
}

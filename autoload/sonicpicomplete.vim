function! sonicpicomplete#GetContext(base)
  let s:line = getline('.')
  let s:synth_re = '\v(use_synth|synth|with_synth|set_current_synth)\s+'
  let s:fx_re = '\vwith_fx\s+'
  let s:sample_re = '\vsample\s+'

  if s:line =~ s:synth_re.':\w+\s*,\s*'
    " Synth is defined; we need the context
    let directive_end = matchend(s:line, 'synth')
    let sound = matchstr(s:line, '\v\w+', directive_end, 1)
    execute 'ruby SonicPiWordlist.get_context("'.sound.'","'.a:base.'")'
    return
  endif

  if s:line =~ s:synth_re
    " Synth is not defined; we need the synth
    execute 'ruby SonicPiWordlist.get_synths("'.a:base.'")'
    return
  endif

  if s:line =~ s:fx_re.':\w+\s*,\s*'
    " FX is defined; we need the context
    let directive_end = matchend(s:line, 'fx')
    let sound = matchstr(s:line, '\v\w+', directive_end, 1)
    execute 'ruby SonicPiWordlist.get_context("'.sound.'","'.a:base.'")'
    return
  endif

  if s:line =~ s:fx_re
    " FX is not defined; we need the FX
    execute 'ruby SonicPiWordlist.get_fx("'.a:base.'")'
    return
  endif

  if s:line =~ s:sample_re.':\w+\s*,\s*'
    " Sample is defined; we need the context
    execute 'ruby SonicPiWordlist.get_context("sample","'.a:base.'")'
    return
  endif

  if s:line =~ s:sample_re
    execute 'ruby SonicPiWordlist.get_samples("'.a:base.'")'
    return
  endif

  " Non-sound contexts
  " #spread is added in 2.4
  if s:line =~ '\vspread\s+\d+\s*,\s*\d+\s*,\s*'
    execute 'ruby SonicPiWordlist.get_context("spread","'.a:base.'")'
    return
  endif

  " If we get to this point, we're looking for directives
  execute 'ruby SonicPiWordlist.get_directives("'.a:base.'")'
endfunction

function! sonicpicomplete#Complete(findstart, base)
  "findstart = 1 when we need to get the text length
  if a:findstart
    let line = getline('.')
    let idx = col('.')
    while idx > 0
      let idx -= 1
      let c = line[idx-1]
      if c =~ '\v[a-z0-9_:]'
        continue
      elseif ! c =~ '\.'
        idx = -1
        break
      else
        break
      endif
    endwhile

    return idx
    "findstart = 0 when we need to return the list of completions
  else
    echom a:base
    let g:sonicpicomplete_completions = []
    call sonicpicomplete#GetContext(a:base)
    return g:sonicpicomplete_completions
  endif
endfunction
function! s:DefRuby()
ruby << RUBYEOF
class SonicPiWordlist
  attr_reader :directives, :synths, :fx, :samples, :context

  def initialize
    # From server/sonicpi/lib/sonicpi/spiderapi.rb
    @directives = []
    @directives += %w(at bools choose comment cue dec density dice factor?)
    @directives += %w(in_thread inc knit live_loop ndefine one_in print)
    @directives += %w(puts quantise rand rand_i range rdist ring rrand)
    @directives += %w(rrand_i rt shuffle sleep spread sync uncomment)
    @directives += %w(use_bpm use_bpm_mul use_random_seed wait with_bpm)
    @directives += %w(with_bpm_mul with_random_seed with_tempo)
    @directives += %w(define defonce)
    # From app/server/ruby/lib/sonicpi/lang/sound.rb
    @directives += %w(all_sample_names buffer chord chord_degree chord_invert chord_names)
    @directives += %w(complex_sampler_args? control)
    @directives += %w(current_synth current_synth_defaults current_sample_defaults current_volume current_transpose current_cent_tuning current_octave current_debug current_arg_checks)
    @directives += %w(degree)
    @directives += %w(fetch_or_cache_sample_path find_sample_with_path)
    @directives += %w(free_job_bus fx_names hz_to_midi job_bus job_fx_group)
    @directives += %w(job_mixer job_proms_joiner job_synth_group)
    @directives += %w(job_synth_proms_add job_synth_proms_rm)
    @directives += %w(join_thread_and_subthreads kill kill_fx_job_group)
    @directives += %w(kill_job_group live_audio load_sample load_sample_at_path load_samples)
    @directives += %w(load_synthdefs midi_notes midi_to_hz)
    @directives += %w(normalise_and_resolve_synth_args normalise_args!)
    @directives += %w(note note_info note_range octs pitch_to_ratio play play_chord play_pattern)
    @directives += %w(play_pattern_timed ratio_to_pitch reboot recording_delete recording_save)
    @directives += %w(recording_start recording_stop reset_mixer! resolve_sample_symbol_path rest? ring sample)
    @directives += %w(sample_buffer sample_duration sample_free sample_free_all sample_groups sample_info)
    @directives += %w(sample_loaded? sample_names sample_paths scale scale_names)
    @directives += %w(scale_time_args_to_bpm! scsynth_info set_audio_latency! set_cent_tuning! set_control_delta!)
    @directives += %w(set_current_synth set_mixer_control! set_mixer_hpf!)
    @directives += %w(set_mixer_hpf_disable! set_mixer_invert_stereo! set_mixer_lpf!)
    @directives += %w(set_mixer_lpf_disable! set_mixer_mono_mode! set_mixer_standard_stereo! set_recording_bit_depth! set_sched_ahead_time!)
    @directives += %w(set_volume! shutdown_job_mixer spread status stop synth synth_names)
    @directives += %w(trigger_chord trigger_fx trigger_inst)
    @directives += %w(trigger_sampler trigger_specific_sampler)
    @directives += %w(trigger_synth trigger_synth_with_resolved_args)
    @directives += %w(use_arg_bpm_scaling use_arg_checks use_cent_tuning use_debug use_external_synths)
    @directives += %w(use_merged_sample_defaults use_merged_synth_defaults use_octave use_sample_bpm use_sample_defaults)
    @directives += %w(use_synth)
    @directives += %w(use_synth_defaults use_timing_guarantees use_timing_warnings)
    @directives += %w(use_transpose use_tuning validate_if_necessary!)
    @directives += %w(with_arg_bpm_scaling with_arg_checks with_cent_tuning with_debug)
    @directives += %w(with_fx with_merged_sample_defaults with_merged_synth_defaults with_octave with_sample_bpm with_sample_defaults)
    @directives += %w(with_synth)
    @directives += %w(with_synth_defaults with_timing_guarantees with_timing_warnings with_transpose with_tuning)
    # from app/server/ruby/lib/sonicpi/lang/midi.rb
    @directives += %w(current_midi_defaults)
    @directives += %w(midi midi_all_notes_off midi_cc midi_channel_pressure midi_clock_beat midi_clock_tick midi_continue midi_local_control_off midi_local_control_on midi_mode midi_note_off midi_note_on midi_pc midi_pitch_bend midi_poly_pressure midi_raw midi_reset midi_sound_off midi_start midi_stop)
    @directives += %w(use_merged_midi_defaults use_midi_defaults use_midi_logging)
    @directives += %w(with_merged_midi_defaults with_midi_defaults with_midi_logging)
    # from app/server/ruby/lib/sonicpi/lang/pattern.rb
    @directives += %w(play_nested_pattern)

    @directives_context = {}
    @directives_context["play"] = ['amp', 'amp_slide', 'pan', 'pan_slide', 'attack', 'decay', 'sustain', 'release', 'attack_level', 'decay_level', 'sustain_level', 'env_curve', 'slide', 'pitch', 'on']
    @directives_context["live_audio"] = ['input', 'stereo', 'stop']
    @directives_context["sample"] = ['rate', 'beat_stretch', 'pitch_stretch', 'attack', 'sustain', 'release', 'start', 'finish', 'pan', 'amp', 'pre_amp', 'onset', 'slice', 'num_slices', 'norm', 'lpf', 'lpf_init_level', 'lpf_attack_level', 'lpf_decay_level', 'lpf_sustain_level', 'lpf_release_level', 'lpf_attack', 'lpf_decay', 'lpf_sustain', 'lpf_release', 'lpf_min', 'lpf_env_curve', 'hpf', 'hpf_init_level', 'hpf_attack_level', 'hpf_decay_level', 'hpf_sustain_level', 'hpf_release_level', 'hpf_attack', 'hpf_decay', 'hpf_sustain', 'hpf_release', 'hpf_env_curve', 'hpf_max', 'rpitch', 'pitch', 'window_size', 'pitch_dis', 'time_dis', 'compress', 'threshold', 'slope_below', 'slope_above', 'clamp_time', 'relax_time', 'slide', 'path']
    @directives_context[note_range] = ['pitches']

     # The synths
    @synths = []
    @context = {}
    context_common = [ 'amp', 'amp_slide', 'amp_slide_shape', 'amp_slide_curve', 'pan', 'pan_slide', 'pan_slide_shape', 'pan_slide_curve', 'attack', 'decay', 'sustain', 'release', 'attack_level', 'decay_level', 'sustain_level' ]
    context_note = [ 'note', 'note_slide', 'note_slide_shape', 'note_slide_curve' ]
    context_cutoff = [ 'cutoff', 'cutoff_slide', 'cutoff_slide_shape', 'cutoff_slide_curve' ]
    context_cutoff_min = [ 'cutoff_min', 'cutoff_min_slide', 'cutoff_min_slide_shape', 'cutoff_min_slide_curve', 'cutoff_attack', 'cutoff_decay', 'cutoff_sustain', 'cutoff_release', 'cutoff_attack_level', 'cutoff_decay_level', 'cutoff_sustain_level' ]
    context_pulse_width = [ 'pulse_width', 'pulse_width_slide', 'pulse_width_slide_shape', 'pulse_width_slide_curve' ]
    context_sub_amp = [ 'sub_amp', 'sub_amp_slide', 'sub_amp_slide_shape', 'sub_amp_slide_curve' ]
    context_sub_detune = [ 'sub_detune', 'sub_detune_slide', 'sub_detune_slide_shape', 'sub_detune_slide_curve' ]
    context_detune = [ 'detune', 'detune_slide', 'detune_slide_shape', 'detune_slide_curve' ]
    context_detune1 = [ 'detune1', 'detune1_slide', 'detune1_slide_shape', 'detune1_slide_curve', 'detune2', 'detune2_slide', 'detune2_slide_shape', 'detune2_slide_curve' ]
    context_dpulse_width = [ 'dpulse_width', 'dpulse_width_slide', 'dpulse_width_slide_shape', 'dpulse_width_slide_curve' ]
    context_divisor = [ 'divisor', 'divisor_slide', 'divisor_slide_shape', 'divisor_slide_curve' ]
    context_depth = [ 'depth', 'depth_slide', 'depth_slide_shape', 'depth_slide_curve' ]
    context_mod_phase = [ 'mod_phase', 'mod_phase_offset' ]
    context_mod_phase_slide = [ 'mod_phase_slide', 'mod_phase_slide_shape', 'mod_phase_slide_curve' ]
    context_mod_range_slide = [ 'mod_range_slide', 'mod_range_slide_shape', 'mod_range_slide_curve' ]
    context_mod_pulse_width_slide = [ 'mod_pulse_width_slide', 'mod_pulse_width_slide_shape', 'mod_pulse_width_slide_curve' ]
    context_res = [ 'res', 'res_slide', 'res_slide_shape', 'res_slide_curve' ]
    context_phase = [ 'phase', 'phase_slide', 'phase_slide_shape', 'phase_slide_curve', 'phase_offset' ]
    context_range = [ 'range', 'range_slide', 'range_slide_shape', 'range_slide_curve' ]
    context_vibrato_rate = [ 'vibrato_rate', 'vibrato_rate_slide_shape', 'vibrato_rate_slide_curve' ]
    context_vibrato_depth = [ 'vibrato_depth', 'vibrato_depth_slide_shape', 'vibrato_depth_slide_curve' ]
    context_freq_band = [ 'freq_band', 'freq_band_slide', 'freq_band_slide_shape', 'freq_band_slide_curve' ]
    @synths += [':beep']
    @context['beep'] = context_common + context_note + [ 'env_curve' ]
    @synths += [':blade']
    @context['blade'] = context_common + context_note + context_cutoff + context_vibrato_rate + context_vibrato_depth + [ 'env_curve', 'vibrato_delay', 'vibrato_onset' ]
    @synths += [':bnoise']
    @context['bnoise'] = context_common + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':chipbass']
    @context['chipbass'] = context_common + context_note + [ 'note_resolution', 'env_curve' ]
    @synths += [':chiplead']
    @context['chiplead'] = context_common + context_note + [ 'note_resolution', 'env_curve', 'width' ]
    @synths += [':chipnoise']
    @context['chipnoise'] = context_common + context_freq_band + [ 'env_curve' ]
    @synths += [':cnoise']
    @context['cnoise'] = context_common + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':dark_ambience']
    @context['dark_ambience'] = context_common + context_note + context_cutoff + context_detune1 + context_res + [ 'env_curve', 'noise', 'ring', 'room', 'reverb_time' ]
    @synths += [':dpulse']
    @context['dpulse'] = context_common + context_note + context_cutoff + context_pulse_width + context_detune + context_dpulse_width + [ 'env_curve' ]
    @synths += [':dsaw']
    @context['dsaw'] = context_common + context_note + context_cutoff + context_detune + [ 'env_curve' ]
    @synths += [':dtri']
    @context['dtri'] = context_common + context_note + context_cutoff + context_detune + [ 'env_curve' ]
    @synths += [':dull_bell']
    @context['dull_bell'] = context_common + context_note + [ 'env_curve' ]
    @synths += [':fm']
    @context['fm'] = context_common + context_note + context_cutoff + context_divisor + context_depth + [ 'env_curve' ]
    @synths += [':gnoise']
    @context['gnoise'] = context_common + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':growl']
    @context['growl'] = context_common + context_note + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':hollow']
    @context['hollow'] = context_common + context_note + context_cutoff + context_res + [ 'env_curve', 'noise', 'norm' ]
    @synths += [':hoover']
    @context['hoover'] = context_common + context_note + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':mod_beep']
    @context['mod_beep'] = context_common + context_note + context_cutoff + context_mod_phase + context_mod_phase_slide + context_mod_range_slide + context_mod_pulse_width_slide + [ 'env_curve', 'mod_range', 'mod_pulse_width', 'mod_invert_wave', 'mod_wave' ]
    @synths += [':mod_dsaw']
    @context['mod_dsaw'] = context_common + context_note + context_cutoff + context_detune + context_mod_phase + context_mod_phase_slide + context_mod_range_slide + context_mod_pulse_width_slide + [ 'env_curve', 'mod_range', 'mod_pulse_width', 'mod_invert_wave', 'mod_wave' ]
    @synths += [':mod_fm']
    @context['mod_fm'] = context_common + context_note + context_cutoff + context_divisor + context_depth + context_mod_phase + [ 'env_curve', 'mod_range', 'mod_pulse_width', 'mod_invert_wave', 'mod_wave' ]
    @synths += [':mod_pulse']
    @context['mod_pulse'] = context_common + context_note + context_cutoff + context_pulse_width + context_mod_phase + context_mod_phase_slide + context_mod_range_slide + context_mod_pulse_width_slide + [ 'env_curve', 'mod_range', 'mod_pulse_width', 'mod_invert_wave', 'mod_wave' ]
    @synths += [':mod_saw']
    @context['mod_saw'] = context_common + context_note + context_cutoff + context_mod_phase + context_mod_phase_slide + context_mod_range_slide + context_mod_pulse_width_slide + [ 'env_curve', 'mod_range', 'mod_pulse_width', 'mod_invert_wave', 'mod_wave' ]
    @synths += [':mod_sine']
    @context['mod_sine'] = context_common + context_note + context_cutoff + context_mod_phase + context_mod_phase_slide + context_mod_range_slide + context_mod_pulse_width_slide + [ 'env_curve', 'mod_range', 'mod_pulse_width', 'mod_invert_wave', 'mod_wave' ]
    @synths += [':mod_tri']
    @context['mod_tri'] = context_common + context_note + context_cutoff + context_mod_phase + context_mod_phase_slide + context_mod_range_slide + context_mod_pulse_width_slide + [ 'env_curve', 'mod_range', 'mod_pulse_width', 'mod_invert_wave', 'mod_wave' ]
    @synths += [':noise']
    @context['noise'] = context_common + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':piano']
    @context['piano'] = context_common + context_note + [ 'vel', 'hard', 'stereo_width' ]
    @synths += [':pluck']
    @context['pluck'] = context_common + context_note + [ 'noise_amp', 'max_delay_time', 'pluck_decay', 'coef' ]
    @synths += [':pnoise']
    @context['pnoise'] = context_common + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':pretty_bell']
    @context['pretty_bell'] = context_common + context_note + [ 'env_curve' ]
    @synths += [':prophet']
    @context['prophet'] = context_common + context_note + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':pulse']
    @context['pulse'] = context_common + context_note + context_cutoff + context_pulse_width + [ 'env_curve' ]
    @synths += [':saw']
    @context['saw'] = context_common + context_note + [ 'env_curve' ]
    @synths += [':sine']
    @context['sine'] = context_common + context_note + [ 'env_curve' ]
    @synths += [':sound_in']
    @context['sound_in'] = context_common + [ 'env_curve', 'input' ]
    @synths += [':sound_in_stereo']
    @context['sound_in_stereo'] = context_common + [ 'env_curve', 'input' ]
    @synths += [':square']
    @context['square'] = context_common + context_note + context_cutoff + [ 'env_curve' ]
    @synths += [':subpulse']
    @context['subpulse'] = context_common + context_note + context_cutoff + context_pulse_width + context_sub_amp + context_sub_detune + [ 'env_curve' ]
    @synths += [':supersaw']
    @context['supersaw'] = context_common + context_note + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':tb303']
    @context['tb303'] = context_common + context_note + context_cutoff + context_cutoff_min + context_pulse_width + context_res + [ 'env_curve', 'wave' ]
    @synths += [':tech_saws']
    @context['tech_saws'] = context_common + context_note + context_cutoff + context_res + [ 'env_curve' ]
    @synths += [':tri']
    @context['tri'] = context_common + context_note + context_cutoff + context_pulse_width + [ 'env_curve' ]
    @synths += [':zawa']
    @context['zawa'] = context_common + context_note + context_cutoff + context_pulse_width + context_res + context_phase + context_range + [ 'wave', 'invert_wave', 'disable_wave' ]

    # The samples
    @samples = [ ':drum_heavy_kick', ':drum_tom_mid_soft', ':drum_tom_mid_hard', ':drum_tom_lo_soft', ':drum_tom_lo_hard', ':drum_tom_hi_soft', ':drum_tom_hi_hard', ':drum_splash_soft', ':drum_splash_hard', ':drum_snare_soft', ':drum_snare_hard', ':drum_cymbal_soft', ':drum_cymbal_hard', ':drum_cymbal_open', ':drum_cymbal_closed', ':drum_cymbal_pedal', ':drum_bass_soft', ':drum_bass_hard', ':drum_cowbell', ':drum_roll', ':elec_triangle', ':elec_snare', ':elec_lo_snare', ':elec_hi_snare', ':elec_mid_snare', ':elec_cymbal', ':elec_soft_kick', ':elec_filt_snare', ':elec_fuzz_tom', ':elec_chime', ':elec_bong', ':elec_twang', ':elec_wood', ':elec_pop', ':elec_beep', ':elec_blip', ':elec_blip2', ':elec_ping', ':elec_bell', ':elec_flip', ':elec_tick', ':elec_hollow_kick', ':elec_twip', ':elec_plip', ':elec_blup', ':guit_harmonics', ':guit_e_fifths', ':guit_e_slide', ':guit_em9', ':misc_burp', ':misc_crow', ':misc_cineboom', ':perc_bell', ':perc_bell2', ':perc_snap', ':perc_snap2', ':perc_swash', ':perc_till', ':perc_door', ':perc_impact1', ':perc_impact2', ':perc_swoosh', ':ambi_soft_buzz', ':ambi_swoosh', ':ambi_drone', ':ambi_glass_hum', ':ambi_glass_rub', ':ambi_haunted_hum', ':ambi_piano', ':ambi_lunar_land', ':ambi_dark_woosh', ':ambi_choir', ':ambi_sauna', ':bass_hit_c', ':bass_hard_c', ':bass_thick_c', ':bass_drop_c', ':bass_woodsy_c', ':bass_voxy_c', ':bass_voxy_hit_c', ':bass_dnb_f', ':sn_dub', ':sn_dolf', ':sn_zome', ':sn_generic', ':bd_ada', ':bd_pure', ':bd_808', ':bd_zum', ':bd_gas', ':bd_sone', ':bd_haus', ':bd_zome', ':bd_boom', ':bd_klub', ':bd_fat', ':bd_tek', ':bd_mehackit', ':loop_industrial', ':loop_compus', ':loop_amen', ':loop_amen_full', ':loop_garzul', ':loop_mika', ':loop_breakbeat', ':loop_safari', ':loop_tabla', ':loop_3d_printer', ':loop_drone_g_97', ':loop_electric', ':loop_mehackit1', ':loop_mehackit2', ':loop_perc1', ':loop_perc2', ':loop_weirdo', ':tabla_tas1', ':tabla_tas2', ':tabla_tas3', ':tabla_ke1', ':tabla_ke2', ':tabla_ke3', ':tabla_na', ':tabla_na_o', ':tabla_tun1', ':tabla_tun2', ':tabla_tun3', ':tabla_te1', ':tabla_te2', ':tabla_te_ne', ':tabla_te_m', ':tabla_ghe1', ':tabla_ghe2', ':tabla_ghe3', ':tabla_ghe4', ':tabla_ghe5', ':tabla_ghe6', ':tabla_ghe7', ':tabla_ghe8', ':tabla_dhec', ':tabla_na_s', ':tabla_re', ':glitch_bass_g', ':glitch_perc1', ':glitch_perc2', ':glitch_perc3', ':glitch_perc4', ':glitch_perc5', ':glitch_robot1', ':glitch_robot2', ':vinyl_backspin', ':vinyl_rewind', ':vinyl_scratch', ':vinyl_hiss', ':mehackit_phone1', ':mehackit_phone2', ':mehackit_phone3', ':mehackit_phone4', ':mehackit_robot1', ':mehackit_robot2', ':mehackit_robot3', ':mehackit_robot4', ':mehackit_robot5', ':mehackit_robot6', ':mehackit_robot7' ]

    # The FX
    @fx = [ ':bitcrusher', ':krush', ':reverb', ':gverb', ':level', ':mono', ':echo', ':slicer', ':panslicer', ':wobble', ':ixi_techno', ':compressor', ':whammy', ':rlpf', ':nrlpf', ':rhpf', ':nrhpf', ':hpf', ':nhpf', ':lpf', ':nlpf', ':normaliser', ':distortion', ':pan', ':bpf', ':nbpf', ':rbpf', ':nrbpf', ':band_eq', ':tanh', ':pitch_shift', ':ring_mod', ':octaver', ':vowel', ':flanger', ':eq', ':tremolo', ':record', ':sound_out', ':sound_out_stereo' ]
  end

  def return_to_vim(completions)
    list = array2list(completions)
    VIM::command("call extend(g:sonicpicomplete_completions, [%s])" % list)
  end

  def self.get_context(sound, base)
    s = SonicPiWordlist.new
    list = s.context[sound].collect do |e|
      e.to_s + ":"
    end.sort
    if base != ''
      list = list.grep(/^#{base}/)
    end
    s.return_to_vim(list)
  end

  def self.get_synths(base)
    s = SonicPiWordlist.new
    list = s.synths.grep(/^#{base}/).sort
    s.return_to_vim(list)
  end

  def self.get_fx(base)
    s = SonicPiWordlist.new
    list = s.fx.grep(/^#{base}/).sort
    s.return_to_vim(list)
  end

  def self.get_samples(base)
    s = SonicPiWordlist.new
    list = s.samples.grep(/^#{base}/).sort
    s.return_to_vim(list)
  end

  def self.get_directives(base)
    s = SonicPiWordlist.new
    list = s.directives.grep(/^#{base}/).sort
    s.return_to_vim(list)
  end

  private
  def array2list(array)
    list = array.join('","')
    list.gsub!(/^(.)/, '"\1')
    list.gsub!(/(.)$/, '\1"')
    list
  end
end
RUBYEOF
endfunction
call s:DefRuby()

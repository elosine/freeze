(s.options.numAudioBusChannels = 300;s.options.memSize = 81920;s.waitForBoot{fork{
	var path = "/Users/jyang/GitHub/freeze/";

	//Groups
	s.sendMsg(\g_new, 900, 1, 1);
	10.do{|ix| s.sendMsg(\g_new, 901+ix, 3, 900+ix)};

	////Buffer for Icy Effect
	s.sendMsg( \b_alloc, 200, (30*44100), 1 );
	s.sendMsg( \b_alloc, 201, (30*44100), 1 );
	////Envelope Buffers
	s.sendMsg(\b_allocRead, 100, path ++ "grainEnv/gEnv_3stageLinear.aif");
	s.sendMsg(\b_allocRead, 101,  path ++ "grainEnv/gEnv_hanning.aif");
	s.sendMsg(\b_allocRead, 102,  path ++ "grainEnv/gEnv_gauss.aif");
	s.sendMsg(\b_allocRead, 103,  path ++ "grainEnv/gEnv_blackman.aif");
	s.sendMsg(\b_allocRead, 104,  path ++ "grainEnv/gEnv_hamming.aif");
	s.sendMsg(\b_allocRead, 105,  path ++ "grainEnv/gEnv_quasiGauss.aif");
	s.sendMsg(\b_allocRead, 106,  path ++ "grainEnv/gEnv_blackmanHarris.aif");
	s.sendMsg(\b_allocRead, 107,  path ++ "grainEnv/gEnv_tri.aif");
	s.sendMsg(\b_allocRead, 108,  path ++ "grainEnv/gEnv_expodec.aif");
	s.sendMsg(\b_allocRead, 109,  path ++ "grainEnv/gEnv_rexpodec.aif");


	////Samples
	s.sendMsg(\b_allocRead,0,  path ++ "samples/iceCreamTruckmf.aif");
	s.sendMsg(\b_allocRead,1,  path ++ "samples/Blackbird.aif");
	s.sendMsg(\b_allocRead,2, path ++ "samples/tambura.aif");
	s.sendMsg(\b_allocRead,3, path ++ "samples/unacorda.aif");
	s.sendMsg(\b_allocRead,4, path ++ "samples/mirdangam1.aif");



	////Synth Defs
	SynthDef(\playsamp_s, {
		arg obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,buf,loop=1;
		var src, sig, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		sig = PlayBuf.ar(2, buf,loop:loop);
		Out.ar(obs, sig*amp*env);
	}).add;

	SynthDef(\playsamp_m2s, {
		arg obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,buf,loop=1;
		var src, sig1, sig2, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		sig1 = PlayBuf.ar(1, buf,loop:loop);
		sig2 = DelayC.ar(sig1, 0.2, 0.03);
		Out.ar(obs, [sig1, sig2]*amp*env);
	}).add;


	SynthDef(\icy_s, {
		arg ibs,obs=0, buf1,buf2, envbuf = -1, pitchshift=1, winsz=0.8, overlaps=40,
		resettrig=0, startpos=0.0, endpos=1.0, rand=0.1, ratemin=4, ratemax=0.000001,
		indur=2, t_tr=1, rel=0.3, crv = -6, gate=1, mamp=0.4;
		var sig1, sig2, ix, krate, in1, in2, writehead, whenv, durenv, amp;
		amp = \amp.kr(0.33, 0.03)*mamp;
		durenv = EnvGen.ar(Env.asr(0.01, 1, rel, curve: crv),gate,doneAction:2);
		writehead = Phasor.ar(0, BufRateScale.kr(buf1), 0, BufFrames.kr(buf1));
		whenv = EnvGen.ar(Env.linen(0.0, indur, 0.0), t_tr).poll;
		in1 = BufWr.ar(In.ar(ibs), buf1, writehead*whenv);
		in2 = BufWr.ar(In.ar(ibs+1), buf2, writehead*whenv);
		krate = \rate.kr(1, 0.05).linlin(0.0, 1.0, ratemax, ratemin );
		ix = Phasor.kr(resettrig, ((1.0/ControlRate.ir)/(BufFrames.kr(buf1)/SampleRate.ir))*krate, startpos, endpos);
		sig1 = Warp1.ar(1, buf1, ix, pitchshift, winsz, envbuf, overlaps,rand);
		sig2 = Warp1.ar(1, buf2, ix, pitchshift, winsz, envbuf, overlaps,rand);
		Out.ar(obs, [sig1,sig2]*durenv*amp);
	}).add;

	0.2.wait;

	////Synths

	s.sendMsg(\s_new, \playsamp_s, 10001, 0, 902, \obs, 110, \buf, 0, \amp, 1.0); //icecream truck
	s.sendMsg(\s_new, \playsamp_s, 10002, 0, 902, \obs, 120, \buf, 1, \amp, 1.0); //blackbird
	s.sendMsg(\s_new, \playsamp_s, 10003, 0, 902, \obs, 130, \buf, 2, \amp, 1.0); //tambura
	s.sendMsg(\s_new, \playsamp_s, 10004, 0, 902, \obs, 140, \buf, 3, \amp, 1.0); //unacorda
	s.sendMsg(\s_new, \playsamp_m2s, 10005, 0, 902, \obs, 150, \buf, 4, \amp, 1.0); //mirdangam1


}/*end fork*/}/*end s.waitForBoot*/)

s.sendMsg(\s_new, \icy_s, 5000, 0, 903, \obs, 0, \ibs, 150,\buf1, 200, \buf2, 201, \amp, 1.0);
s.sendMsg(\n_set, 5000, \ibs, 150, \amp, 3.0, \envbuf, 108, \rate, 0.1, \t_tr, 1, \indur, 30, \ratemin, 12);
s.sendMsg(\n_set, 5000,  \rate, 0.45, \envbuf, 108, \amp, 4);
s.sendMsg(\n_set, 5000,  \rate, 0.23, \envbuf, 108);

s.makeGui

s.sendMsg(\n_set, 10005,  \obs, 150);
s.sendMsg(\n_free, 10005);
s.sendMsg(\n_free, 5000);


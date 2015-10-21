(
b = Buffer.read(s, "/Volumes/Ute/Freeze/204497__holadios__short-giggle.wav");
d = SoundFile.collectIntoBuffers("/Volumes/Ute/Freeze/grainEnv/" ++ "*");
e = Buffer.read(s, "/Volumes/Ute/Freeze/acjourney.aif");
f = Buffer.alloc(s, s.sampleRate*2);

SynthDef(\icy_live, {
	arg buf=0, envbuf = -1, pitchshift=1, winsz=0.8, overlaps=40, resettrig=0, startpos=0.0, endpos=1.0, rand=0.1, ratemin=2.0, ratemax=0.00001, indur=1, ingate=1, dur=5, rel=1.2, crv = -6;
	var sig, ix, krate, in, writehead, whenv, durenv;
	durenv = EnvGen.ar(Env.linen(0.01, dur, rel, curve: crv),1,doneAction:2);
	writehead = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	whenv = EnvGen.ar(Env.linen(0.0, indur, 0.0), ingate);
	in = BufWr.ar(SoundIn.ar(0), buf, writehead*whenv);
	krate = \rate.kr(1, 0.05).linlin(0.0, 1.0, ratemin, ratemax);
	ix = Phasor.kr(resettrig, ((1.0/ControlRate.ir)/(BufFrames.kr(buf)/SampleRate.ir))*krate, startpos, endpos);
	sig = Warp1.ar(1, buf, ix, pitchshift, winsz, envbuf, overlaps,rand);
	Out.ar(0, sig*durenv);
}).add;
)

x = Synth(\icy_live, [\buf, f, \winsz, 0.6, \overlaps, 17, \rand, 0.2, \envbuf, d[3],\ratemin,1, \ratemax, 0.00001, \dur, 11, \indur, 2, \rate, 0.97, \rel, 2, \crv, -6 ]);
x.free;
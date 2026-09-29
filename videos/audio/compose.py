import numpy as np
from scipy import signal
import wave

SR = 48000
BPM = 120
BEAT = 60 / BPM
BAR = BEAT * 4
LENGTH = 32.0
CUTS = [4, 10, 14, 18, 21, 24, 28]
DROP = 26.0
N = int(SR * LENGTH)
rng = np.random.default_rng(7)


def midi(note):
    return 440.0 * 2 ** ((note - 69) / 12)


def buffer():
    return np.zeros((N, 2))


def place(bus, sound, start, gain=1.0, pan=0.0):
    i = int(round(start * SR))
    if i >= N:
        return
    mono = sound if sound.ndim == 1 else None
    stereo = sound if sound.ndim == 2 else np.stack([mono * np.sqrt(0.5 - pan / 2), mono * np.sqrt(0.5 + pan / 2)], 1) * np.sqrt(2)
    end = min(N, i + len(stereo))
    bus[i:end] += stereo[: end - i] * gain


def lowpass(x, cutoff, order=2):
    b, a = signal.butter(order, min(cutoff, SR / 2 - 100) / (SR / 2))
    return signal.lfilter(b, a, x, axis=0)


def highpass(x, cutoff, order=2):
    b, a = signal.butter(order, cutoff / (SR / 2), "high")
    return signal.lfilter(b, a, x, axis=0)


def bandpass(x, lo, hi, order=2):
    b, a = signal.butter(order, [lo / (SR / 2), hi / (SR / 2)], "band")
    return signal.lfilter(b, a, x, axis=0)


def saw(freq, t, phase=0.0):
    return 2 * ((freq * t + phase) % 1.0) - 1


def adsr(n, attack, release, sustain_level=1.0):
    env = np.full(n, sustain_level)
    a = min(n, int(attack * SR))
    r = min(n, int(release * SR))
    env[:a] = np.linspace(0, sustain_level, a)
    if r:
        env[-r:] *= np.linspace(1, 0, r)
    return env


CHORDS = {
    "Am": [57, 60, 64, 67, 71],
    "F": [53, 57, 60, 64, 67],
    "C": [48, 55, 60, 64, 67],
    "G": [55, 59, 62, 67, 69],
}
BASS = {"Am": 33, "F": 29, "C": 36, "G": 31}
PROGRESSION = ["Am", "F", "C", "G"] * 3 + ["F", "C", "F", "C"]
HALF_BAR_12 = ["F", "G"]


def chord_at(time):
    bar = int(time // BAR)
    if bar == 12:
        return HALF_BAR_12[int((time % BAR) // (BAR / 2))]
    return PROGRESSION[min(bar, 15)]


def pad_note(freq, dur):
    t = np.arange(int(dur * SR)) / SR
    voices = sum(saw(freq * (1 + d), t, rng.random()) for d in (-0.011, -0.004, 0.0, 0.005, 0.012))
    left = sum(saw(freq * (1 + d), t, rng.random()) for d in (-0.009, 0.003, 0.010))
    x = np.stack([voices + left * 0.4, voices - left * 0.4], 1) / 6
    return highpass(lowpass(x, 2600), 190) * adsr(len(t), 0.35, 0.6)[:, None]


def pluck(freq, dur=0.6, brightness=1.0):
    t = np.arange(int(dur * SR)) / SR
    tone = sum((1 / k) * np.sin(2 * np.pi * freq * k * t) * np.exp(-t * (4 + k * 3.2 / brightness)) for k in range(1, 12))
    return tone * adsr(len(t), 0.002, 0.05) * 0.5


def bass_note(freq, dur):
    t = np.arange(int(dur * SR)) / SR
    tone = np.sin(2 * np.pi * freq * t) + 0.35 * np.sin(4 * np.pi * freq * t) + 0.18 * saw(freq * 2, t)
    tone = np.tanh(tone * 1.6) * adsr(len(t), 0.004, 0.06)
    return lowpass(tone, 900)


def kick():
    t = np.arange(int(0.45 * SR)) / SR
    freq = 46 + 110 * np.exp(-t * 32)
    phase = 2 * np.pi * np.cumsum(freq) / SR
    body = np.sin(phase) * np.exp(-t * 7.5)
    click = highpass(rng.standard_normal(len(t)), 3000) * np.exp(-t * 300) * 0.25
    return np.tanh((body + click) * 1.4)


def clap():
    t = np.arange(int(0.35 * SR)) / SR
    noise = bandpass(rng.standard_normal(len(t)), 900, 4200)
    env = sum(np.exp(-np.clip(t - o, 0, None) * 60) * (t >= o) for o in (0, 0.011, 0.022)) + np.exp(-t * 14) * 0.6
    return noise * env * 0.45


def hat(open_hat=False):
    dur = 0.28 if open_hat else 0.07
    t = np.arange(int(dur * SR)) / SR
    return highpass(rng.standard_normal(len(t)), 7500) * np.exp(-t * (14 if open_hat else 70)) * 0.22


def crash():
    t = np.arange(int(2.6 * SR)) / SR
    x = highpass(rng.standard_normal((len(t), 2)), 4000) * np.exp(-t * 1.9)[:, None]
    return x * 0.35


def boom():
    t = np.arange(int(2.0 * SR)) / SR
    freq = 38 + 60 * np.exp(-t * 6)
    return np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-t * 2.2) * 0.9


def whoosh(length=0.9, peak=0.6):
    n = int(length * SR)
    t = np.arange(n) / SR
    noise = rng.standard_normal((n, 2))
    env = np.where(t < peak, (t / peak) ** 2.2, np.exp(-(t - peak) * 9))
    centers = 500 + 5500 * np.clip(t / peak, 0, 1) ** 2
    out = np.zeros((n, 2))
    step = 1024
    for s in range(0, n, step):
        c = centers[min(s, n - 1)]
        out[s:s + step] = bandpass(noise[s:s + step + 0], c * 0.6, min(c * 1.6, SR / 2 - 200), 1)
    out = lowpass(out, 9000)
    pan = np.sin(np.linspace(-1.2, 1.2, n))
    out[:, 0] *= env * (1 - pan * 0.4)
    out[:, 1] *= env * (1 + pan * 0.4)
    return out * 0.5, peak


def riser(length):
    n = int(length * SR)
    t = np.arange(n) / SR
    noise = rng.standard_normal((n, 2))
    out = np.zeros((n, 2))
    step = 2048
    for s in range(0, n, step):
        c = 400 + 7000 * (s / n) ** 2
        out[s:s + step] = bandpass(noise[s:s + step], c * 0.7, min(c * 1.4, SR / 2 - 200), 1)
    return out * ((t / length) ** 2.5)[:, None] * 0.55


def reverb(x, seconds=2.4):
    n = int(seconds * SR)
    t = np.arange(n) / SR
    ir = rng.standard_normal((n, 2)) * np.exp(-t * 3.0)[:, None]
    ir = lowpass(ir, 6000)
    ir /= np.sqrt((ir ** 2).sum(0))
    return np.stack([signal.fftconvolve(x[:, c], ir[:, c])[:N] for c in range(2)], 1)


def in_section(time, name):
    bar = int(time // BAR)
    groove = 2 <= bar <= 11 or bar == 13
    return {
        "kick": groove,
        "clap": groove,
        "hats": groove,
        "bass": 2 <= bar <= 13,
        "arp": True,
        "open": 6 <= bar <= 11 or bar == 13,
    }[name]


pads, plucks, bass, drums, fx = buffer(), buffer(), buffer(), buffer(), buffer()

for bar in range(16):
    start = bar * BAR
    if bar == 12:
        for half, name in enumerate(HALF_BAR_12):
            for note in CHORDS[name]:
                place(pads, pad_note(midi(note), BAR / 2 + 0.6), start + half * BAR / 2, 0.55)
        continue
    name = PROGRESSION[bar]
    length = BAR + 0.6 if bar < 15 else BAR + 1.5
    for note in CHORDS[name]:
        place(pads, pad_note(midi(note), length), start, 0.55)

ARP_SHAPE = [0, 2, 3, 4, 3, 2, 1, 2]
for step in range(int(LENGTH / (BEAT / 4))):
    time = step * BEAT / 4
    if time > 31.0:
        break
    notes = CHORDS[chord_at(time)]
    index = ARP_SHAPE[step % len(ARP_SHAPE)]
    note = notes[index] + (12 if (step // 8) % 2 else 0)
    level = 0.16 if time < 4 else 0.22
    accent = 1.25 if step % 4 == 0 else 1.0
    place(plucks, pluck(midi(note + 12), 0.5, 0.8 + 0.4 * (step % 4 == 0)), time, level * accent, pan=0.35 * np.sin(step * 0.7))

for eighth in range(int(LENGTH / (BEAT / 2))):
    time = eighth * BEAT / 2
    if not in_section(time, "bass") or eighth % 2 == 0:
        continue
    place(bass, bass_note(midi(BASS[chord_at(time)]), BEAT / 2 * 0.9), time, 0.55)

kick_times = []
for b in range(int(LENGTH / BEAT)):
    time = b * BEAT
    if in_section(time, "kick"):
        place(drums, kick(), time, 0.9)
        kick_times.append(time)
    if in_section(time, "clap") and b % 2 == 1:
        place(drums, clap(), time, 0.8)
    if in_section(time, "hats"):
        place(drums, hat(in_section(time, "open")), time + BEAT / 2, 0.9, pan=0.2)
        if in_section(time, "open"):
            place(drums, hat(), time + BEAT / 4, 0.45, pan=-0.25)
            place(drums, hat(), time + BEAT * 3 / 4, 0.45, pan=-0.25)

for i, time in enumerate(np.arange(24.0 + BEAT * 4, DROP, BEAT / 4)):
    place(drums, clap(), time, 0.25 + 0.5 * (time - 26.0 + 2) / 2)

place(fx, riser(1.9), DROP - 1.9, 0.9)
for moment in (0.0, DROP, 28.0):
    place(fx, crash(), moment, 0.7 if moment else 0.4)
    place(drums, boom(), moment, 0.8 if moment else 0.35)
for cut in CUTS:
    sound, peak = whoosh()
    place(fx, sound, cut - peak, 0.55)
sound, peak = whoosh(1.4, 1.0)
place(fx, sound, 0.5 - peak if 0.5 - peak > 0 else 0, 0.0)

duck = np.ones(N)
for time in kick_times:
    i = int(time * SR)
    n = int(0.32 * SR)
    shape = 1 - 0.55 * np.exp(-np.arange(n) / SR * 11)
    end = min(N, i + n)
    duck[i:end] = np.minimum(duck[i:end], shape[: end - i])
duck = duck[:, None]

music = (pads * 0.6 * duck + plucks * duck + bass * duck + drums)
wet = highpass(reverb(pads * 0.4 + plucks * 0.9), 260)
mix = music + wet * 0.35 * duck + fx
mix = highpass(mix, 30)
b, a = signal.iirpeak(250 / (SR / 2), 0.8)
mix = mix - 0.35 * signal.lfilter(b, a, mix, axis=0)

fade = np.ones(N)
tail = int(1.8 * SR)
fade[-tail:] = np.linspace(1, 0, tail) ** 1.5
head = int(0.02 * SR)
fade[:head] = np.linspace(0, 1, head)
mix *= fade[:, None]

mix /= np.max(np.abs(mix))
mix = np.tanh(mix * 1.3) / np.tanh(1.3) * 0.89

pcm = (mix * 32767).astype(np.int16)
with wave.open("public/audio/soundtrack.wav", "wb") as out:
    out.setnchannels(2)
    out.setsampwidth(2)
    out.setframerate(SR)
    out.writeframes(pcm.tobytes())
print("peak", np.max(np.abs(mix)))

import numpy as np
import matplotlib.pyplot as plt

class LFSR_Simulator:
    def __init__(self, seed=0x01, taps=0x8E):
        self.seed = seed & 0xFF
        self.taps = taps & 0xFF
        self.lfsr_reg = self.seed
        self.active = False

    def start(self):
        self.lfsr_reg = self.seed
        self.active = True

    def stop(self):
        self.active = False

    def set_seed(self, seed):
        self.seed = seed & 0xFF

    def set_taps(self, taps):
        self.taps = taps & 0xFF

    def get_next_value(self):
        if not self.active:
            return None
        feedback = 0
        for i in range(8):
            if (self.taps >> i) & 1:
                feedback ^= (self.lfsr_reg >> i) & 1
        self.lfsr_reg = ((self.lfsr_reg << 1) | feedback) & 0xFF
        return self.lfsr_reg

    def generate_sequence(self, length):
        self.start()
        values = []
        for _ in range(length):
            values.append(self.lfsr_reg)
            self.get_next_value()
        return values


def plot_probability_distribution(sequence):
    plt.figure(figsize=(12, 6))
    density, bins, _ = plt.hist(sequence, bins=256, density=True, alpha=0.0)
    center = (bins[:-1] + bins[1:]) / 2
    plt.plot(center, density, color='blue')
    plt.title("Probability Distribution of LFSR Output")
    plt.xlabel("LFSR Output Value")
    plt.ylabel("Probability Density")
    plt.grid(True, axis='y')
    plt.show()


def analyze_lfsr(seed=0x01, taps=0x8E, sequence_length=256):
    lfsr = LFSR_Simulator(seed, taps)
    sequence = lfsr.generate_sequence(sequence_length)

    plot_probability_distribution(sequence)

    unique_values = set()
    cycle_length = 0
    for value in sequence:
        if value in unique_values:
            break
        unique_values.add(value)
        cycle_length += 1

    print(f"LFSR Analysis:")
    print(f"- Seed: 0x{seed:02X}")
    print(f"- Taps: 0x{taps:02X} (Binary: {taps:08b})")
    print(f"- Number of unique values: {len(unique_values)} out of {len(sequence)}")
    print(f"- Cycle length (period): {cycle_length}")

    return sequence


if __name__ == "__main__":
    DEFAULT_SEED = 0x01
    DEFAULT_TAPS = 0x8E
    print("LFSR Simulator based on provided Verilog implementation")
    print("Default configuration:")
    print(f"- Seed: 0x{DEFAULT_SEED:02X}")
    print(f"- Taps: 0x{DEFAULT_TAPS:02X} (Binary: {DEFAULT_TAPS:08b})")
    sequence = analyze_lfsr(DEFAULT_SEED, DEFAULT_TAPS, 240)

"""
```
kendall([i=5], [α=2.0], [μ=1.0], [ν=0.5])
```
Kendall's birth-death-immigration process.

- `i`: initial number of particles
- `α`: birth rate
- `μ`: death rate
- `ν`: immigration rate
"""
function kendall(
  i :: Integer = 5,
  α :: Float64 = 2.0,
  μ :: Float64 = 1.0,
  ν :: Float64 = 0.5)
  m = Network("Kendall's Process")

  m <= Species("X", i)

  m <= Reaction("birth",       α, "X --> X + X")
  m <= Reaction("death",       μ, "X --> 0")
  m <= Reaction("immigration", ν, "0 --> X")

  return m
end

"""
```
linear(M, x0)
```
A linear chain system of `M` particle types, starting from `x0` initial particles of type 1. Taken from Cao, Li, & Petzold 2004.

- `M`: the number of particle types
- `x0`: the initial number of particles
"""
function linear(
  M  :: Integer,
  x0 :: Integer)
  m = Network("linear chain ($M)")

  m <= Species("S1", x0)

  for i = 2:(M+1)
      m <= Species("S$(i)", 0)
  end

  for i = 1:M
      m <= Reaction("R$(i)", 1.0, "S$(i) --> S$(i+1)")
  end

  return m
end

"""
```
independent(M, x0)
```
A system of independent reactions; there is a reaction for each of the `M` particle types.

- `M`: the number of particle types
- `x0`: the initial number of particles for each type
"""
function independent(M, x0)
  m = Network("independent system $(M)")

  for i in 1:M
    m <= Species("S$(i)", x0)
    m <= Reaction("R$(i)", 1.0, "S$(i) --> 0")
  end

  return m
end

"""
```
autoreg([k1=1.0], [k1r=10.0], [k2=0.01], [k3=10.0], [k4=1.0], [k4r=1.0], [k5=0.1], [k6=0.01])
```
A simple prokaryotic auto-regulation network. RNA is transcribed from a particular gene and translated into a protein. The protein regulates its own transcription by forming a dimer that binds to a transcription site.

- `k1`: repression rate
- `k1r`: reverse repression rate
- `k2`: transcription rate
- `k3`: translation rate
- `k4`: dimerization rate
- `k4r`: dissociation rate
- `k5`: RNA degradation rate
- `k6`: protein degradation rate
"""
function autoreg(;k1=1.0, k1r=10.0, k2=0.01, k3=10.0, k4=1.0, k4r=1.0, k5=0.1, k6=0.01)
  m = Network("auto-regulation")

  m <= Species("gene",   10)
  m <= Species("P2_gene", 0)
  m <= Species("RNA",     0)
  m <= Species("P",       0)
  m <= Species("P2",      0)

  m <= Reaction("repression binding", k1, "gene + P2 --> P2_gene")
  m <= Reaction("reverse repression binding", k1r, "P2_gene --> gene + P2")
  m <= Reaction("transcription", k2, "gene --> gene + RNA")
  m <= Reaction("translation", k3, "RNA --> RNA + P")
  m <= Reaction("dimerization", k4, "P + P --> P2")
  m <= Reaction("dissociation", k4r, "P2 --> P + P")
  m <= Reaction("RNA degradation", k5, "RNA --> 0")
  m <= Reaction("protein degradation", k6, "P --> 0")

  return m
end

"""
```
sir(s, i, r, [β=0.1], [γ=0.05])
```
A Susceptible-Infected-Recovered model. The rate of infection is computed as `β / (s + i + r)`.

- `s`: the initial number of susceptible individuals
- `i`: the initial number of infected individuals
- `r`: the initial number of recovered individals
- `β`: the infection rate for the population
- `γ`: the recovery rate
"""
function sir(
  s :: Integer,
  i :: Integer,
  r :: Integer;
  β :: Real = 0.1,
  γ :: Real = 0.05)
m = Network("SIR")
m <= Species("S", s)
m <= Species("I", i)
m <= Species("R", r)
m <= Reaction("infection", β / (s + i + r), "S + I --> I + I")
m <= Reaction("recovery", γ, "I --> R")
end

"""
```
Network(id)
```

Construct an empty `Network` representing a system of interacting particles. A particle is represented by a `Species`, and an interaction is represented by a `Reaction`.

Add a `Species` or `Reaction` using `<=`:

```
m <= Species("X", 100) # Adds a Species
m <= Reaction("birth", 2.0, "X --> X + X")
```

Simulate a `Network` by calling `simulate`:

```
simulate(m, SSA, time=1000.0, epochs=1000, trials=100)
```

Visualize a `Network` as a Petri net:

```
visualize(m)
```

See also: `Species`, `Reaction`, `simulate`, `visualize`

### Arguments
- `id`: An string identifier for the `Network`.
"""
struct Network
  id :: String

  species_list   :: Dict{Symbol,Species}
  reaction_list  :: Dict{Symbol,Reaction}

  function Network(id)
    s = Dict{Symbol,Species}()
    r = Dict{Symbol,Reaction}()

    return new(string(id), s, r)
  end
end

"Retrieve `Species` from a `Network`."
species_list(x::Network)   = x.species_list

"Retrieve `Reaction`s from a `Network`."
reaction_list(x::Network)  = x.reaction_list

n_species(x::Network)    = length(species_list(x))
n_reactions(x::Network)  = length(reaction_list(x))

function Base.show(io::IO, x::Network)
  print(io, "[ Model: $(x.id) ]\n")
  print(io, " no. species:    $(n_species(x))\n")
  print(io, " no. reactions:  $(n_reactions(x))")
end

function add_object!(model, object, fieldname)
  dict = getfield(model, fieldname)
  id   = object.id
  setindex!(dict, object, Symbol(id))
  return model
end

function (<=)(model::Network, object::Species)
  add_object!(model, object, :species_list)
end

function (<=)(model::Network, object::Reaction)
  reactants = object.reactants
  products  = object.products
  try
    validate(reactants, model)
    validate(products,  model)
    add_object!(model, object, :reaction_list)
  catch ex
    rethrow(ex)
  end
end

function validate(participants, model)
  species_dict = species_list(model)
  for species in keys(participants)
    if !haskey(species_dict, Symbol(species))
      error("$(species) is not defined.")
    end
  end
end

function rmv_object!(model, key, fieldname)
  dict = getfield(model, fieldname)
  if haskey(dict, key)
    delete!(dict, key)
  else
    error("$(key) not found in $(fieldname)")
  end
  return model
end

# function (>=)(model::Network, x::Pair{Symbol,UTF8String})
#   fieldname = x.first
#   key = x.second
#
#   if fieldname == :species_list || :species
#     # remove all species refs in reactions?
#   end
#
#   rmv_object!(model, key, fieldname)
# end

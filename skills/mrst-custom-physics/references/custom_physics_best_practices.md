# MRST Custom Physics Best Practices & Framework Traps

This reference covers robust structural invariants and common framework traps when extending MRST's AD-OO framework. It focuses on how to avoid silently breaking the automatic differentiation (AD) graph or the object-oriented structure.

## 1. `StateFunctionGrouping` Instantiation Trap

When subclassing a model and overriding property functions (e.g., `PVTPropertyFunctions`, `FlowPropertyFunctions`), you must explicitly instantiate the `StateFunctionGrouping` object *before* assigning properties to it. 

If you attempt to assign a `StateFunction` to an uninstantiated grouping, MATLAB will silently create a plain `struct` instead of a `StateFunctionGrouping` object. This breaks the model initialization, as MRST expects a `StateFunctionGrouping` object with its associated framework methods.

**Incorrect (Silently creates a plain struct):**
```matlab
classdef CustomModel < PhysicalModel
    methods
        function model = CustomModel(G, rock, fluid, varargin)
            model = model@PhysicalModel(G, rock, fluid, varargin{:});
            
            % TRAP: If model.PVTPropertyFunctions is not yet a StateFunctionGrouping object,
            % MATLAB turns it into a generic struct. The framework will break later.
            model.PVTPropertyFunctions.Viscosity = CustomViscosity(model);
        end
    end
end
```

**Correct (Explicit instantiation of the specific property group):**
```matlab
classdef CustomModel < PhysicalModel
    methods
        function model = CustomModel(G, rock, fluid, varargin)
            model = model@PhysicalModel(G, rock, fluid, varargin{:});
            
            % FIX: Explicitly instantiate the specific property grouping first
            model.PVTPropertyFunctions = PVTPropertyFunctions(model);
            
            % Now it is safe to assign the custom property
            model.PVTPropertyFunctions.Viscosity = CustomViscosity(model);
        end
    end
end
```

## 2. Primary Variable Dependency Rule

**Always specify the `'state'` grouping when declaring a primary variable dependency inside a `StateFunction`'s `dependsOn()` method.**

In MRST's AD-OO framework, primary variables (e.g., `pressure`) are the independent variables that form the root of the AD graph and reside in the `state` struct. If you list a primary variable as an internal dependency without specifying its grouping, the framework will look for it in the current `StateFunctionGrouping`, which will fail and break the dependency graph.

**Incorrect (Missing the 'state' grouping):**
```matlab
classdef CustomViscosity < StateFunction
    methods
        function gp = CustomViscosity(model, varargin)
            gp@StateFunction(model, varargin{:});
            
            % TRAP: Listing 'pressure' without the 'state' grouping!
            % The framework will try to find 'pressure' in the current grouping.
            gp = gp.dependsOn({'pressure', 'Temperature'}); 
        end
    end
end
```

**Correct:**
Primary variables must be explicitly declared as external dependencies from the `'state'` grouping. Other calculated state functions in the same grouping (like `Temperature` in this example) are listed without a grouping.

```matlab
classdef CustomViscosity < StateFunction
    methods
        function gp = CustomViscosity(model, varargin)
            gp@StateFunction(model, varargin{:});
            
            % FIX: Explicitly declare 'pressure' with the 'state' grouping.
            gp = gp.dependsOn({'pressure'}, 'state'); 
            gp = gp.dependsOn({'Temperature'}); 
        end
        
        function mu = evaluateOnDomain(prop, model, state)
            % Retrieve primary variables using getProp or directly from state
            p = model.getProp(state, 'pressure');
            
            % Retrieve StateFunction dependencies via getEvaluatedDependencies
            T = prop.getEvaluatedDependencies(state, 'Temperature');
            
            % ... calculate viscosity ...
        end
    end
end
```

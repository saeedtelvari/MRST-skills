classdef PressureDependentViscosity < StateFunction
    methods
        function gp = PressureDependentViscosity(model, varargin)
            gp@StateFunction(model, varargin{:});
            % Primary variables (like 'pressure') live in the 'state' struct,
            % NOT in any StateFunctionGrouping. You MUST specify 'state'.
            gp = gp.dependsOn({'pressure'}, 'state');
        end
        
        function mu = evaluateOnDomain(prop, model, state)
            % Retrieve pressure directly from primary variables
            p = model.getProp(state, 'pressure');
            
            % Base viscosity for [Water, Oil]
            mu_base = [1, 10] * 1e-3; % centi*poise in SI
            
            % Scale viscosity with pressure
            scale = 1 + 1e-4 * (p / barsa);
            
            % Return a cell array containing viscosity for each phase
            mu = {mu_base(1) * scale, mu_base(2) * scale};
        end
    end
end

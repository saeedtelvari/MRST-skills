classdef CustomTwoPhaseModel < TwoPhaseOilWaterModel
    methods
        function model = CustomTwoPhaseModel(G, rock, fluid, varargin)
            % Initialize parent model
            model = model@TwoPhaseOilWaterModel(G, rock, fluid, varargin{:});
            
            % Ensure PVTPropertyFunctions is instantiated (prevents MATLAB from creating a struct)
            if isempty(model.PVTPropertyFunctions)
                model.PVTPropertyFunctions = PVTPropertyFunctions(model);
            end
            % Inject our custom StateFunction into the property groupings
            model.PVTPropertyFunctions = model.PVTPropertyFunctions.setStateFunction('Viscosity', PressureDependentViscosity(model));
        end
    end
end

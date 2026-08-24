% import_eclipse_deck.m
% Example script demonstrating how to import an Eclipse deck (.DATA file)
% and extract grid, rock, and fluid properties.

% 1. Standard initialization
run('database/MRST-main/startup.m');
mrstModule add deckformat ad-core ad-blackoil ad-props

% 2. Get path to the built-in SPE9 dataset
pth = getDatasetPath('spe9');
fn  = fullfile(pth, 'BENCH_SPE9.DATA');

% 3. Read Eclipse deck and convert units to metric (MRST standard)
deck = readEclipseDeck(fn);
deck = convertDeckUnits(deck);

% 4. Build grid from Eclipse keywords and compute geometry
G = initEclipseGrid(deck);
G = computeGeometry(G);

% 5. Extract rock and fluid properties
rock = initEclipseRock(deck);
fluid = initDeckADIFluid(deck);

% 6. Plot the grid with porosity data
figure;
plotCellData(G, rock.poro);
title('SPE9 Porosity');
colorbar;
view(3);
axis tight;

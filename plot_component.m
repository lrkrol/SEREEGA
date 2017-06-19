function h = plot_component(component, epochs, leadfield)

n = numel(component);

h = figure; 
j = 0;
for i = 1:n
    if n > 10, m = 10; else, m = n; end
    
    subplot(m,3,(i-j-1)*3+1);
    plot_component_projection(component(i), leadfield, 'newfig', 0);

    subplot(m,3,(i-j-1)*3+[2 3]);
    plot_component_signal(component(i), epochs, 'newfig', 0);

    set(gcf,'Color',[.95 .95 .95]);
    
    if mod(i, 10) == 0
        h(end+1) = figure;
        j = j + 10;
    end
end

end
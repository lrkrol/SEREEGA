function h = plot_component(component, epochs, leadfield)

n = numel(component);


subplot(1,3,1);
plot_component_projection(component, leadfield, 'newfig', 0);

subplot(1,3,[2 3]);
plot_component_signal(component, epochs, 'newfig', 0);

end
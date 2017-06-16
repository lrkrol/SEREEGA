% to add new classes of signal activations to SEREEGA, the following files,
% containing functions of the same name, must be supplied. <class> denotes 
% the name of the new class.

% <class>_check_class - takes a class structure and verifies/completes it
% to pass the requirements of the new class. this is where the class
% documentation should be provided.

% <class>_generate_signal_fromclass - takes a (verified) class structure,
% an epochs configuration structure, and (at least accepts) an epochNumber
% argument. returns a 1-by-nsamples signal activation time course.

% <class>_plot_signal_fromclass - takes a (verified) class structure,
% an epochs configuration structure, and (at least) accepts the optional
% 'newfig' and 'baseonly' arguments. plots the signal activation as per
% <class>_generate_signal_fromclass. returns the figure handle if a new
% figure was opened.
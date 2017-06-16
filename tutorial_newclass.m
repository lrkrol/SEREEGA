% to add new classes of signal activations to SEREEGA, the following files,
% containing functions of the same name, must be supplied. <class> denotes 
% the name of the new class.

% <class>_check_class - takes a class structure, verifies/completes it
% to pass the requirements of the new class, and returns a class variable
% that is compatible with all other functions. this is also where the class
% documentation should be provided.

% <class>_generate_signal_fromclass - takes a (verified) class structure,
% an epochs configuration structure, and (at least accepts) an epochNumber
% argument. returns a 1-by-nsamples signal activation time course.

% <class>_plot_signal_fromclass - takes a (verified) class structure,
% an epochs configuration structure, and (at least) accepts the optional
% 'newfig' and 'baseonly' arguments. this plots a/the signal activation and
% returns the figure handle if a new figure was opened.
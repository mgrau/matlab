function out=dirfun(varargin)
% dirfun    Applies a functio to each file in a folder
%     out = dirfun(FUN, DIR) applies the function specified by FUN to each
%     file in the directory DIR. It will return the output of the function
%     in a cell array.
% 
%     out = dirfun(FUN, DIR, 'pattern', PATTERN) applies the function
%     specified by FUN to each file in the directory DIR whose filename
%     matches the regular expression PATTERN.
% 
%     out = dirfun(FUN, DIR, 'recursive', TRUE) applies the function
%     specified by FUN to each file in the directory DIR, exploring the
%     directory DIR recursively.

%% Input Parser
p = inputParser;
addOptional(p,'fun',@(x) x);
addOptional(p,'dir','.',@ischar);
addParameter(p,'pattern','',@ischar);
addParameter(p,'recursive',false,@islogical);
parse(p,varargin{:});

fun = p.Results.fun;
dir = p.Results.dir;
pattern = p.Results.pattern;
recursive = p.Results.recursive;

%% Call a system command to get filenames. This is Windows specific!
if recursive
    args = '/s';
else
    args = '';
end
[~,s] = system(['dir ' dir '/b ' args]);
% split the output lines into different cells
s = strsplit(s,'\n')';
% remove the last cell - it's always empty.
s = s(1:end-1);

% If a regular expression is given, filter the filenames to only include
% matches
if ~isempty(pattern)
    s = s(cellfun(@(x) ~isempty(x),regexp(s,pattern,'once')));
end

% If not recursive, append the original folder name
if ~recursive
    if dir(end)~=filesep
        dir = [dir filesep];
    end
    s = cellfun(@(s) [dir s],s,'uni',false);
end

% Apply the function to the filenames.
out = cellfun(fun,s,'uni',false);

end

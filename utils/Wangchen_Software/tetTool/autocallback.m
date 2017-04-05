function autocallback(hObject)
%automate the callback programmally.
%

%hgfeval(strrep(get(hObject,'Callback'),'gcbo','hObject'));

cb = get(hObject,'Callback');
if ischar(cb) && ~isempty(strfind(cb,'gcbo'))  %cb is returned as string
    cb = strrep(cb,'gcbo','hObject');
    hgfeval(cb);
else 
    hgfeval(cb,hObject,[]); %cb is function handel
end
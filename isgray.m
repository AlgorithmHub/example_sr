function bool = isgray (img)

# variant of isgray:
# Allow double image entries to be outside [0:1] interval
  if (nargin != 1)
    print_usage ();
  endif

  bool = false;
  if (ndims (img) < 5 && size (img, 3) == 1)
    switch (class (img))
      case "double"
##       original: image entries must be in the interval [0:1]
#        bool = ispart (@is_double_image, img);
##        Allow double image entries to be outside [0:1] interval
         bool = true;
      case {"uint8", "uint16", "int16"}
        bool = true;
    endswitch
  endif

endfunction

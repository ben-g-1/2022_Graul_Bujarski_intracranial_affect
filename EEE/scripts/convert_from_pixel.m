function rating = convert_from_pixel(p, pixel)

pixel = pixel - (.1*p.ptb.screenXpixels);
pixel = pixel / (0.8*p.ptb.screenXpixels);
rating = (pixel*6)+1;
end
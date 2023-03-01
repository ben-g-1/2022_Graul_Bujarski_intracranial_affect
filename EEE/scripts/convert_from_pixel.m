function rating = convert_from_pixel(pixel):

rating = (pix_prcnt*0.8*p.ptb.screenXpixels) + (.1)

rating = (pixel - (0.1*p.ptb.screenXpixels))
rating = rating*0.8
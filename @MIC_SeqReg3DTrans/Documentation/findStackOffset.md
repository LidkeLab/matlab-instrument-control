
findStackOffset estimates a sub-pixel offset between two stacks.
findStackoffset() will estimate the offset between two 3D stacks of
images.  This method computes an integer pixel offset between the two
stacks via a cross-correlation (xcorr) or an xcorr like method, and
then fits a 2nd order polynomial to the resulting xcorr.  An
estimate of a sub-pixel offset is then produced by determining the
location of the peak in the 2nd order polynomial fit.
NOTE: The convention used here for the offset is based on indices as
follows: If Stack is a 3D stack of images, and
Stack1 = Stack(m:n, m:n, m:n)
Stack2 = Stack((m:n)+x, (m:n)+y, (m:n)+z)
then PixelOffset = findStackOffset(Stack1, Stack2) == [x; y; z]

INPUTS:
Stack1:     (mxnxo) The stack to which Stack2 is compared to, i.e.
Stack1 is the reference stack.
Stack2:     (pxqxr) The stack for which the offset relative to Stack1
is to be determined.
MaxOffset:  (3x1 or 1x3)(default = [2; 2; 2]) Maximum offset between
Stack1 and Stack2 to be considered in the calculation of
PixelOffset and SubPixelOffset.
Method:     (string/character array)(default = 'FFT') Method used to
compute the 3D xcorr coefficient field or xcorr like
coefficient field.
'FFT' uses an FFT on the stacks (which are also 'whitened',
i.e. mean subtracted and scaled by their
auto-correlation) to compute a xcorr coefficient field
which is then appropriately scaled by the xcorr
coefficient field of two binary stacks of size(Stack1),
size(Stack2), respectively.
'OLRW' computes an xcorr like coefficient field by brute
force, meaning that the coefficient field is computed
like a xcorr but the overlapping portions of Stack1 and
Stack2 are  re-whitened for the computation of each
point in the xcorr coefficient field.
FitType:    (string/character array)(default = '3DLineFits') The type
of polynomial fit used to fit the 3D xcorr coefficient
field.
'1D' fits 2nd order polynomials to three lines parallel to
x, y, and z which intersect the integer peak of the
xcorr coefficient field.  The fit is determined via
least-squares independently for each of the three
polynomials. Note that only 2 points on either side of
the peak are incorporated into the fitting (5 points
total, unless near an edge).
'3D' fits a 2nd order polynomial (with cross terms) to the
3D xcorr coefficient field using the least-squares
method.
'3DLineFits' fits a 2nd order polynomial (w/o cross terms)
to three lines parallel to x, y, and z which intersect
the integer peak of the xcorr coefficient field.
Unlike in the '1D' method, the polynomial fit for this
method is computed via the least-squares method in a
global sense, i.e. we fit the 3D polynomial (w/o cross
terms) to the union of the data along all three lines.
Note that only 2 points on either side of the peak are
incorporated into the fitting (5 points total, unless
near an edge).

OUTPUTS:
PixelOffset:    (3x1)(integer) The integer pixel offset of Stack2
relative to Stack1, determined based on the location of
the peak of the xcorr coefficient field between the two
stacks.
SubPixelOffset: (3x1)(float) The sub-pixel offset of Stack2 relative to
Stack1, approximated based on a 2nd order polynomial
fit(s) to the xcorr coefficient field as specified by
the FitType input and finding the peak of that
polynomial.
CorrAtOffset:   (float) The maximum value of the correlation
coefficient/fit.  For FitType = '1D', this is the value
of the max xcorr coefficient corresponding to
PixelOffset.  For FitType = '3D' and '3DLineFits', this
is one of the extrema (ideally a maximum) of the
polynomial fit, corresponding to the location of the
returned SubPixelOffset.
MaxOffset:      (3x1 or 1x3) Maximum offset between Stack1 and Stack2
considered in the calculation of PixelOffset and
SubPixelOffset.  This is returned because the user
input value of MaxOffset is truncated if too large.

CITATION:

Created by:
David Schodt (LidkeLab 2018)


Set default parameter values if needed.

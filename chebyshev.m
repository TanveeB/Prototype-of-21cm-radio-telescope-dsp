clc;
f0    = 1420e6;          % centre frequency (Hz)
BW    = 110e6;           % bandwidth (Hz)
Rp    = 0.01;            % passband ripple (dB)
n     = 9;               % filter order

f_low  = f0 - BW/2;     % lower passband edge = 1365 MHz
f_high = f0 + BW/2;     % upper passband edge = 1475 MHz

omega0     = 2*pi*f0;
omega_low  = 2*pi*f_low;
omega_high = 2*pi*f_high;
B_rad      = omega_high - omega_low;   % bandwidth in rad/s
fprintf('  Centre frequency  f0     = %.1f MHz\n', f0/1e6);
fprintf('  Bandwidth         BW     = %.1f MHz\n', BW/1e6);
fprintf('  Lower edge        f_low  = %.1f MHz\n', f_low/1e6);
fprintf('  Upper edge        f_high = %.1f MHz\n', f_high/1e6);
fprintf('  Passband ripple   Rp     = %.2f dB\n', Rp);
fprintf('  Filter order      n      = %d\n', n);

eps_sq = 10^(Rp/10) - 1;
eps    = sqrt(eps_sq);

arcsinh_term = asinh(1/eps) / n;
poles_lp = zeros(1, n);
for k = 1:n
    theta_k  = pi * (2*k - 1) / (2*n);
    sigma_k  = -sin(theta_k) * sinh(arcsinh_term);
    omega_k  =  cos(theta_k) * cosh(arcsinh_term);
    poles_lp(k) = complex(sigma_k, omega_k);
    fprintf('  p_%2d = %+.6f + j(%+.6f)\n', k, sigma_k, omega_k);
end

% Design analog bandpass Chebyshev Type I filter
[b_a, a_a] = cheby1(n, Rp, [omega_low, omega_high], 's');

% Get poles, zeros, gain
[z_a, p_a, k_a] = cheby1(n, Rp, [omega_low, omega_high], 's');

fprintf('\n  Gain constant k = %.4e\n', k_a);
fprintf('\n  Poles of H(s) — %d total:\n', length(p_a));
for i = 1:length(p_a)
    fprintf('    p_%2d = %+.4e + j(%+.4e)   [f = %.2f MHz]\n', ...
        i, real(p_a(i)), imag(p_a(i)), abs(imag(p_a(i)))/(2*pi*1e6));
end


% Evaluate frequency response
freqs_hz = linspace(0.8e9, 2.0e9, 100000);
w_rad    = 2*pi*freqs_hz;
H_a      = freqs(b_a, a_a, w_rad);
mag_db   = 20*log10(abs(H_a) + 1e-15);
peak     = max(mag_db);

% -3 dB bandwidth
idx3   = find(mag_db >= peak - 3);
f_3l   = freqs_hz(idx3(1));
f_3h   = freqs_hz(idx3(end));
bw3    = f_3h - f_3l;
fc3    = (f_3h + f_3l) / 2;

% Passband ripple
pm  = (freqs_hz >= f_low) & (freqs_hz <= f_high);
rip = max(mag_db(pm)) - min(mag_db(pm));

% Stopband attenuation
sl    = (freqs_hz >= 1.0e9) & (freqs_hz <= 1.2e9);
sh    = (freqs_hz >= 1.62e9) & (freqs_hz <= 1.9e9);
att_l = peak - max(mag_db(sl));
att_h = peak - max(mag_db(sh));


figure('Name', '9th Order Chebyshev Bandpass Filter', ...
       'NumberTitle', 'off', 'Position', [100 100 1200 800]);

% --- Plot 1: Full magnitude response ---
subplot(2,2,1);
plot(freqs_hz/1e6, mag_db, 'b', 'LineWidth', 1.5); hold on;
xline(f_low/1e6,  'r--', sprintf('f_{low} = %.0f MHz', f_low/1e6),  'LabelVerticalAlignment','bottom');
xline(f_high/1e6, 'g--', sprintf('f_{high} = %.0f MHz', f_high/1e6),'LabelVerticalAlignment','bottom');
xline(f0/1e6,     'k:',  sprintf('f_0 = %.0f MHz', f0/1e6),         'LabelVerticalAlignment','bottom');
yline(peak - 3,   'm:',  '-3 dB');
xlim([1000 1900]); ylim([-120 5]);
xlabel('Frequency (MHz)'); ylabel('Magnitude (dB)');
title('Magnitude Response'); grid on;

% --- Plot 2: Passband zoom ---
subplot(2,2,2);
zoom_idx = (freqs_hz >= 1.3e9) & (freqs_hz <= 1.55e9);
plot(freqs_hz(zoom_idx)/1e6, mag_db(zoom_idx), 'b', 'LineWidth', 1.5); hold on;
xline(f_low/1e6,  'r--'); xline(f_high/1e6, 'g--'); xline(f0/1e6, 'k:');
xlabel('Frequency (MHz)'); ylabel('Magnitude (dB)');
title('Passband Detail (1300 – 1550 MHz)'); grid on;

% --- Plot 3: Phase response ---
subplot(2,2,3);
phase_deg = angle(H_a) * 180/pi;
plot(freqs_hz/1e6, phase_deg, 'Color', [0.5 0 0.8], 'LineWidth', 1.5); hold on;
xline(f_low/1e6,  'r--'); xline(f_high/1e6, 'g--');
xlim([1000 1900]);
xlabel('Frequency (MHz)'); ylabel('Phase (degrees)');
title('Phase Response'); grid on;

% --- Plot 4: Pole-Zero plot ---
subplot(2,2,4);
scatter(real(p_a)/(2*pi*1e6), imag(p_a)/(2*pi*1e6), ...
    80, 'rx', 'LineWidth', 1.5); hold on;
if ~isempty(z_a)
    scatter(real(z_a)/(2*pi*1e6), imag(z_a)/(2*pi*1e6), ...
        60, 'bo', 'LineWidth', 1.5);
end
yline( f0/1e6, 'g:', sprintf('+f_0 = %.0f MHz', f0/1e6));
yline(-f0/1e6, 'g:', sprintf('-f_0 = %.0f MHz', f0/1e6));
axline_h = yline(0, 'k', 'LineWidth', 0.5);
axline_v = xline(0, 'k', 'LineWidth', 0.5);
xlabel('Real part / 2\pi (MHz)');
ylabel('Imaginary part / 2\pi (MHz)');
title('Pole-Zero Plot');
legend('Poles', 'Zeros', 'Location', 'best');
grid on;

sgtitle({'9th Order Chebyshev Type I Bandpass Filter', ...
         'f_0 = 1420 MHz,  BW = 110 MHz,  R_p = 0.01 dB'}, ...
        'FontSize', 13);

fprintf('\n=================================================================\n');
fprintf('  TRANSFER FUNCTION SUMMARY\n');
fprintf('=================================================================\n');
fprintf('\n  H(s) = K * prod[1/(s - p_k)]  for k = 1..18\n');
fprintf('\n  |H(jw)|^2 = 1 / [1 + eps^2 * C_9^2( (w^2-w0^2)/(B*w) )]\n');
fprintf('\n  where:\n');
fprintf('    eps  = %.6f  (ripple factor, Rp = %.2f dB)\n', eps, Rp);
fprintf('    w0   = %.4e rad/s  (2*pi*%.0f MHz)\n', omega0, f0/1e6);
fprintf('    B    = %.4e rad/s  (2*pi*%.0f MHz)\n', B_rad, BW/1e6);
fprintf('    C_9  = Chebyshev polynomial of order 9\n');
fprintf('    K    = %.4e\n', k_a);
fprintf('\n  Done.\n');
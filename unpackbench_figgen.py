# -*- coding: utf-8 -*-
import json
import matplotlib.pyplot as plt
import numpy as np
import os, sys

results_erofs = sys.argv[1]
results_overlay = sys.argv[2]
out = sys.argv[3]

erofs_data = None
overlay_data = None

with open(results_erofs) as json_data:
    erofs_data = json.load(json_data)
    json_data.close()

with open(results_overlay) as json_data:
    overlay_data = json.load(json_data)
    json_data.close()

COLOR_EROFS = '#4c78a8'
COLOR_OVERLAY = '#f58518'

fig_height = len(erofs_data) * 0.5 + 2          # Dynamically adjust height based on data
fig, ax = plt.subplots(figsize=(14, fig_height))

names = [item['name'] for item in erofs_data]
erofs_means = [float(item['mean']) for item in erofs_data]
erofs_stds = [float(item['stddev']) for item in erofs_data]
overlay_means = [float(item['mean']) for item in overlay_data]
overlay_stds = [float(item['stddev']) for item in overlay_data]

# Y-axis positions (reversed so first item appears at top)
y_pos = np.arange(len(names))[::-1]

bar_height = 0.35

# Draw EROFS and OverlayFS bars (upper position in each group)
bars1 = ax.barh(y_pos + bar_height/2, erofs_means, height=bar_height,
                xerr=erofs_stds, capsize=5, color=COLOR_EROFS,
                alpha=0.8, label='EROFS', error_kw={'ecolor': '#333333', 'lw': 1.5})

bars2 = ax.barh(y_pos - bar_height/2, overlay_means, height=bar_height,
                xerr=overlay_stds, capsize=5, color=COLOR_OVERLAY,
                alpha=0.8, label='OverlayFS', error_kw={'ecolor': '#333333', 'lw': 1.5})

# Add labels for EROFS and OverlayFS
for i, (v, e) in enumerate(zip(erofs_means, erofs_stds)):
    ax.text(v + e + 0.15, y_pos[i] + bar_height/2, f'{v:.2f}',
            va='center', fontsize=9, color='#333333', fontweight='bold')

for i, (v, e) in enumerate(zip(overlay_means, overlay_stds)):
    ax.text(v + e + 0.15, y_pos[i] - bar_height/2, f'{v:.2f}',
            va='center', fontsize=9, color='#333333', fontweight='bold')


# Set Y-axis labels
ax.set_yticks(y_pos)
ax.set_yticklabels(names, fontsize=10, fontfamily='monospace')

# Set title and axis labels
ax.set_title('Containerd Image Unpacking Performance: EROFS vs OverlayFS (Mean ± SD)',
             fontsize=14, fontweight='bold', pad=20)
ax.set_xlabel('Time (s)', fontsize=12)

# Add legend
ax.legend(loc='upper right', fontsize=11, framealpha=0.9)

# Add grid lines (X-axis only)
ax.grid(axis='x', linestyle='--', alpha=0.3, color='#999999')
ax.set_axisbelow(True)

# Set X-axis range (leave space for labels)
max_value = max(max(erofs_means), max(overlay_means))
ax.set_xlim(0, max_value * 1.15)

# Remove top and right borders
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# Adjust layout to prevent label cutoff
plt.tight_layout()
plt.subplots_adjust(left=0.25)  # Leave space for long names

_, ext = os.path.splitext(out)
if ext == '.svg':
    plt.savefig(out, format='svg', bbox_inches='tight')
elif ext == '.png':
    plt.savefig(out, format='png', dpi=300, bbox_inches='tight')

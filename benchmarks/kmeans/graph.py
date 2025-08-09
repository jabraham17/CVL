import pandas as pd
import numpy as np

import matplotlib.pyplot as plt

# Read the CSV file
df = pd.read_csv("clusters.csv", names=["x", "y", "clusterId"])

# Create a scatter plot with different colors for each cluster
plt.figure(figsize=(10, 8))
unique_clusters = df["clusterId"].unique()
colors = plt.cm.tab10(np.linspace(0, 1, len(unique_clusters)))

for i, cluster_id in enumerate(unique_clusters):
    cluster_data = df[df["clusterId"] == cluster_id]
    plt.scatter(
        cluster_data["x"],
        cluster_data["y"],
        c=[colors[i]],
        label=f"Cluster {cluster_id}",
        alpha=0.7,
    )

plt.xlabel("X")
plt.ylabel("Y")
plt.title("Data Clusters")
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

import setuptools

with open("README.MD", 'r') as f:
    long_description = f.read()

setuptools.setup(
   name='RutishauserLabtoNWB',
   version='1.1.0',
   description='Export and Analysis Code for NWB:N',
   license="BSD",
   long_description=long_description,
   long_description_content_type = 'text/markdown',
   author='Nand Chandravadia',
   author_email='nand.chandravadia@cshs.org',
    packages=['RutishauserLabtoNWB', 'RutishauserLabtoNWB/assets', 'RutishauserLabtoNWB/events/newolddelay',
              'RutishauserLabtoNWB/events/newolddelay/python/analysis', 'RutishauserLabtoNWB/events/newolddelay/python/analysis/demo',
              'RutishauserLabtoNWB/events/newolddelay/python/export',
              'RutishauserLabtoNWB/events/newolddelay/python/export/demo', 'RutishauserLabtoNWB/InHouse', 'RutishauserLabtoNWB/NWBData'],
   install_requires=['numpy', 'pandas', 'scipy', 'matplotlib', 'pynwb==1.1.0', 'opencv-python', 'hdmf==1.2.0', 'seaborn'], #external packages as dependencies
   keywords = ['Cognitive Neuroscience', 'Neuroscience', 'Neurosurgery', 'Single Unit Recordings', 'Data Standardization'],
    include_package_data=True,
    classifiers=[ "Programming Language :: Python :: 3", "Operating System :: OS Independent"],
    url = 'https://github.com/rutishauserlab/recogmem-release-NWB',
    python_requires='>=3.0'
)





from pndniworkflows.preprocessing import crop_wf
from pndniworkflows.interfaces.io import ExportFile
import sys
from pathlib import Path
from nipype.pipeline import engine as pe


if __name__ == '__main__':
    infile = sys.argv[1]
    outfile = sys.argv[2]
    model = sys.argv[3]
    points = sys.argv[4]
    wd = sys.argv[5]
    crop = crop_wf(True)
    wf = pe.Workflow('wrapper')
    wf.base_dir = wd
    crop.inputs.inputspec.T1 = str(Path(infile).resolve())
    crop.inputs.inputspec.model = str(Path(model).resolve())
    crop.inputs.inputspec.points = str(Path(points).resolve())
    export = pe.Node(ExportFile(out_file=str(Path(outfile).resolve())), 'export')
    wf.connect(crop, 'outputspec.cropped', export, 'in_file')
    wf.run()
